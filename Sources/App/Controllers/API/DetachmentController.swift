import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class DetachmentController {
    
    // MARK: - Public Functions
    
    func createDetachment(_ req: Request) throws -> Future<DetachmentResponse> {
        return try req.content.decode(CreateDetachmentRequest.self)
            .flatMap(to: Detachment.self, { request in
                return Army.find(request.armyId, on: req)
                    .unwrap(or: RoasterHammerError.armyIsMissing.error())
                    .flatMap(to: Detachment.self, { army in
                        let armyId = try army.requireID()
                        return Detachment(name: request.name,
                                          commandPoints: request.commandPoints,
                                          armyId: armyId)
                            .save(on: req)
                    })
                    .flatMap(to: Detachment.self, { detachment in
                        return try self.generateRoles(forDetachment: detachment, conn: req)
                    })
            })
            .flatMap(to: DetachmentResponse.self, { detachment in
                return try self.detachmentResponse(forDetachment: detachment, conn: req)
            })
    }
    
    func detachments(_ req: Request) throws -> Future<[Detachment]> {
        return Detachment.query(on: req).all()
    }
    
    func detachmentTypes(_ req: Request) throws -> Future<[DetachmentShortResponse]> {
        let detachmentTypes = [
            (Constants.DetachmentName.patrol, 0),
            (Constants.DetachmentName.batallion, 5),
            (Constants.DetachmentName.brigade, 12),
            (Constants.DetachmentName.spearhead, 1),
            (Constants.DetachmentName.vanguard, 1),
            (Constants.DetachmentName.outrider, 1)
            ].map { DetachmentShortResponse(name: $0.0, commandPoints: $0.1)}
        
        return req.eventLoop.future(detachmentTypes)
    }
    
    func addDetachmentToRoaster(_ req: Request) throws -> Future<RoasterResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let roasterId = try req.parameters.next(Int.self)
        
        return try req.content.decode(AddDetachmentToRoasterRequest.self)
            .flatMap(to: Detachment.self, { request in
                // Might need to duplicate the detachment for the roaster to avoid collusion
                return Detachment
                    .find(request.detachmentId, on: req)
                    .unwrap(or: RoasterHammerError.detachmentIsMissing.error())
            })
            .flatMap(to: Roaster.self, { detachment in
                return Roaster.find(roasterId, on: req)
                    .unwrap(or: RoasterHammerError.roasterIsMissing.error())
                    .then({ roaster in
                        return roaster.detachments.attach(detachment, on: req)
                            .then ({ _ in
                                return req.future(roaster)
                            })
                    })
            })
            .flatMap(to: RoasterResponse.self, { roaster in
                let roasterController = RoasterController()
                return try roasterController.roasterResponse(forRoaster: roaster, conn: req)
            })
    }
    
    func selectDetachmentFaction(_ req: Request) throws -> Future<RoasterResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let roasterId = try req.parameters.next(Int.self)
        let detachmentId = try req.parameters.next(Int.self)
        let factionId = try req.parameters.next(Int.self)
        
        return Detachment
            .find(detachmentId, on: req)
            .unwrap(or: RoasterHammerError.detachmentIsMissing.error())
            .flatMap(to: Detachment.self, { detachment in
                detachment.factionId = factionId
                return detachment.update(on: req)
            })
            .flatMap(to: Roaster.self, { _ in
                return Roaster.find(roasterId, on: req)
                    .unwrap(or: RoasterHammerError.roasterIsMissing.error())
            })
            .flatMap(to: RoasterResponse.self, { roaster in
                let roasterController = RoasterController()
                return try roasterController.roasterResponse(forRoaster: roaster, conn: req)
            })
    }
    
    // MARK: - Utility Functions
    
    func roleResponse(forRole role: Role,
                      conn: DatabaseConnectable) throws -> Future<RoleResponse> {
        return try role.units.query(on: conn).all()
            .flatMap(to: [SelectedUnitResponse].self, { units in
                let unitDatabaseQueries = UnitDatabaseQueries()
                return try units
                    .map { try unitDatabaseQueries.selectedUnitResponse(forSelectedUnit: $0, conn: conn) }
                    .flatten(on: conn)
            })
            .map(to: RoleResponse.self, { units in
                let roleDTO = RoleDTO(id: try role.requireID(), name: role.name)
                return RoleResponse(role: roleDTO, units: units)
            })
    }
    
    func detachmentResponse(forDetachment detachment: Detachment,
                            conn: DatabaseConnectable) throws -> Future<DetachmentResponse> {
        let rolesFuture = try detachment.roles.query(on: conn).all()
        let armyFuture = detachment.army.get(on: conn)
        let selectedFactionFuture = Faction.find(detachment.factionId ?? -1, on: conn)
        
        return flatMap(rolesFuture,
                       armyFuture,
                       selectedFactionFuture, { (roles, army, selectedFaction) in
                        let roleResponsesFuture = try roles
                            .map { try self.roleResponse(forRole: $0, conn: conn) }
                            .flatten(on: conn)
                        let armyResponse = try ArmyController().armyResponse(forArmy: army, conn: conn)
                        let detachmentDTO = DetachmentDTO(id: try detachment.requireID(),
                                                          name: detachment.name,
                                                          commandPoints: detachment.commandPoints)
                        
                        if let selectedFaction = selectedFaction {
                            let selectedFactionResponse = try FactionController().factionResponse(faction: selectedFaction,
                                                                                                  conn: conn)
                            
                            return map(roleResponsesFuture,
                                       armyResponse,
                                       selectedFactionResponse, { (roleResponses, armyResponse, selectedFactionResponse) in
                                        return DetachmentResponse(detachment: detachmentDTO,
                                                                  selectedFaction: selectedFactionResponse,
                                                                  roles: roleResponses,
                                                                  army: armyResponse)
                            })
                        } else {
                            return map(roleResponsesFuture, armyResponse, { (roleResponses, armyResponse) in
                                return DetachmentResponse(detachment: detachmentDTO,
                                                          selectedFaction: nil,
                                                          roles: roleResponses,
                                                          army: armyResponse)
                            })
                        }
        })
        
    }

    func getDetachmentById(_ detachmentId: Int, conn: DatabaseConnectable) throws -> Future<DetachmentResponse> {
        return Detachment.find(detachmentId, on: conn)
            .unwrap(or: RoasterHammerError.detachmentIsMissing.error())
            .flatMap(to: DetachmentResponse.self, { detachment in
                return try self.detachmentResponse(forDetachment: detachment, conn: conn)
            })
    }
    
    func minMaxUnits(forDetachment detachment: Detachment, andRole role: Role) -> (min: Int, max: Int) {
        switch (detachment.name, role.name) {
        // Patrol
        case (Constants.DetachmentName.patrol, Constants.RoleName.hq):
            return (1, 2)
        case (Constants.DetachmentName.patrol, Constants.RoleName.troop):
            return (1, 3)
        case (Constants.DetachmentName.patrol, _):
            return (0, 2)
        // Batallion
        case (Constants.DetachmentName.batallion, Constants.RoleName.hq):
            return (2, 3)
        case (Constants.DetachmentName.batallion, Constants.RoleName.troop):
            return (3, 6)
        case (Constants.DetachmentName.batallion, Constants.RoleName.elite):
            return (0, 6)
        case (Constants.DetachmentName.batallion, Constants.RoleName.fastAttack),
             (Constants.DetachmentName.batallion, Constants.RoleName.heavySupport):
            return (0, 3)
        case (Constants.DetachmentName.batallion, Constants.RoleName.flyer):
            return (0, 2)
        // Brigade
        case (Constants.DetachmentName.brigade, Constants.RoleName.hq):
            return (3, 5)
        case (Constants.DetachmentName.brigade, Constants.RoleName.troop):
            return (6, 12)
        case (Constants.DetachmentName.brigade, Constants.RoleName.elite):
            return (3, 8)
        case (Constants.DetachmentName.brigade, Constants.RoleName.fastAttack),
             (Constants.DetachmentName.brigade, Constants.RoleName.heavySupport):
            return (3, 5)
        case (Constants.DetachmentName.brigade, Constants.RoleName.flyer):
            return (0, 2)
        // Vanguard
        case (Constants.DetachmentName.vanguard, Constants.RoleName.hq):
            return (1, 2)
        case (Constants.DetachmentName.vanguard, Constants.RoleName.troop):
            return (0, 3)
        case (Constants.DetachmentName.vanguard, Constants.RoleName.elite):
            return (3, 6)
        case (Constants.DetachmentName.vanguard, _):
            return (0, 2)
        // Spearhead
        case (Constants.DetachmentName.spearhead, Constants.RoleName.hq):
            return (1, 2)
        case (Constants.DetachmentName.spearhead, Constants.RoleName.troop):
            return (0, 3)
        case (Constants.DetachmentName.spearhead, Constants.RoleName.heavySupport):
            return (3, 6)
        case (Constants.DetachmentName.spearhead, _):
            return (0, 2)
        // Outrider
        case (Constants.DetachmentName.outrider, Constants.RoleName.hq):
            return (1, 2)
        case (Constants.DetachmentName.outrider, Constants.RoleName.fastAttack):
            return (3, 6)
        case (Constants.DetachmentName.outrider, _):
            return (0, 2)
        default:
            return (0, 0)
        }
    }
    
    // MARK: - Private Functions
    
    private func generateRoles(forDetachment detachment: Detachment,
                               conn: DatabaseConnectable) throws -> Future<Detachment> {
        let detachmentId = try detachment.requireID()
        let rolesFutures = [
            Role(name: Constants.RoleName.hq, detachmentId: detachmentId).save(on: conn),
            Role(name: Constants.RoleName.troop, detachmentId: detachmentId).save(on: conn),
            Role(name: Constants.RoleName.elite, detachmentId: detachmentId).save(on: conn),
            Role(name: Constants.RoleName.fastAttack, detachmentId: detachmentId).save(on: conn),
            Role(name: Constants.RoleName.heavySupport, detachmentId: detachmentId).save(on: conn),
            Role(name: Constants.RoleName.flyer, detachmentId: detachmentId).save(on: conn)
        ]
        
        return rolesFutures.flatten(on: conn).then({ _ in
            return conn.future(detachment)
        })
    }
    
}
