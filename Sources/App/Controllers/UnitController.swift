import Vapor
import FluentPostgreSQL

final class UnitController {

    // MARK: - Public Functions

    func createUnit(_ req: Request) throws -> Future<UnitResponse> {
        return try req.content.decode(CreateUnitRequest.self)
            .flatMap(to: Unit.self, { request in
                return Unit(name: request.name, cost: request.cost).save(on: req)
                    .flatMap(to: Characteristics.self, { unit in
                        let unitId = try unit.requireID()
                        return Characteristics(movement: request.characteristics.movement,
                                               weaponSkill: request.characteristics.weaponSkill,
                                               balisticSkill: request.characteristics.balisticSkill,
                                               strength: request.characteristics.strength,
                                               toughness: request.characteristics.toughness,
                                               wounds: request.characteristics.wounds,
                                               attacks: request.characteristics.attacks,
                                               leadership: request.characteristics.leadership,
                                               save: request.characteristics.save,
                                               unitId: unitId)
                            .save(on: req)
                    })
                    .flatMap(to: Unit.self, { characteristics in
                        return characteristics.unit.get(on: req)
                    })
            })
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitResponse(forUnit: unit, conn: req)
            })
    }

    func units(_ req: Request) throws -> Future<[UnitResponse]> {
        return Unit.query(on: req).all()
            .flatMap(to: [UnitResponse].self, { units in
                return try units.map { try self.unitResponse(forUnit: $0, conn: req) }.flatten(on: req)
            })
    }

    func addUnitToDetachmentUnitRole(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let roleId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)

        return Role.find(roleId, on: req)
            .unwrap(or: RoasterHammerError.roleIsMissing)
            .flatMap(to: UnitRole.self, { role in
                return Unit.find(unitId, on: req)
                    .unwrap(or: RoasterHammerError.unitIsMissing)
                    .flatMap(to: UnitRole.self, { unit in
                        return role.units.attach(unit, on: req)
                    })
            })
            .flatMap(to: Detachment.self, { _ in
                return Detachment.find(detachmentId, on: req)
                    .unwrap(or: RoasterHammerError.detachmentIsMissing)
            })
            .flatMap(to: DetachmentResponse.self, { detachment in
                let detachmentController = DetachmentController()
                return try detachmentController.detachmentResponse(forDetachment: detachment, conn: req)
            })
    }

    // MARK: - Utility Functions

    func unitResponse(forUnit unit: Unit, conn: DatabaseConnectable) throws -> Future<UnitResponse> {
        return try unit.characteristics
            .query(on: conn)
            .first()
            .unwrap(or: RoasterHammerError.unitIsMissing)
            .map(to: UnitResponse.self, { characteristics in
                return try UnitResponse(unit: unit, characteristics: characteristics)
        })
    }

}
