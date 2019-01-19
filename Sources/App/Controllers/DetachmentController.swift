import Vapor
import FluentPostgreSQL

final class DetachmentController {

    // MARK: - Public Functions

    func createDetachment(_ req: Request) throws -> Future<DetachmentResponse> {
        return try req.content.decode(Detachment.self)
            .flatMap(to: Detachment.self, { detachment in
                return detachment.save(on: req)
                    .flatMap(to: Detachment.self, { detachment in
                        return try self.generateRoles(forDetachment: detachment, conn: req)
                    })
            })
            .flatMap(to: DetachmentResponse.self, { detachment in
                return try self.detachmentResponse(forDetachment: detachment, conn: req)
            })
    }

    func detachments(_ req: Request) throws -> Future<[DetachmentResponse]> {
        return Detachment.query(on: req).all()
            .flatMap(to: [DetachmentResponse].self, { detachments in
                let response = try detachments.map { try self.detachmentResponse(forDetachment: $0, conn: req) }
                return response.flatten(on: req)
            })
    }

    func addDetachmentToArmy(_ req: Request) throws -> Future<ArmyResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let armyId = try req.parameters.next(Int.self)

        return try req.content.decode(AddDetachmentToArmyRequest.self)
            .flatMap(to: Detachment.self, { request in
                return Detachment.find(request.detachmentId, on: req).unwrap(or: RoasterHammerError.detachmentIsMissing)
            })
            .flatMap(to: Army.self, { detachment in
                return Army.find(armyId, on: req).unwrap(or: RoasterHammerError.armyIsMissing).then({ army in
                    return army.detachments.attach(detachment, on: req).then({ _ in
                        return req.future(army)
                    })
                })
            })
            .flatMap(to: ArmyResponse.self, { army in
                let armyController = ArmyController()
                return try armyController.armyResponse(forArmy: army, conn: req)
            })
    }

    // MARK: - Utility Functions

    func detachmentResponse(forDetachment detachment: Detachment,
                            conn: DatabaseConnectable) throws -> Future<DetachmentResponse> {
        return try detachment.roles.query(on: conn).all()
            .map(to: DetachmentResponse.self, { roles in
                return try DetachmentResponse(detachment: detachment, roles: roles)
            })
    }

    func generateRoles(forDetachment detachment: Detachment, conn: DatabaseConnectable) throws -> Future<Detachment> {
        let detachmentId = try detachment.requireID()
        let rolesFutures = [
            Role(name: "HQ", detachmentId: detachmentId).save(on: conn),
            Role(name: "Troop", detachmentId: detachmentId).save(on: conn),
            Role(name: "Elite", detachmentId: detachmentId).save(on: conn),
            Role(name: "Fast Attack", detachmentId: detachmentId).save(on: conn),
            Role(name: "Heavy Support", detachmentId: detachmentId).save(on: conn)
        ]

        return rolesFutures.flatten(on: conn).then({ _ in
            return conn.future(detachment)
        })
    }

}
