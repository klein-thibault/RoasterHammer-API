import Vapor
import FluentPostgreSQL

final class UnitController {

    func createUnit(_ req: Request) throws -> Future<Unit> {
        return try req.content.decode(CreateUnitRequest.self).flatMap(to: Unit.self, { request in
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
    }

    func units(_ req: Request) throws -> Future<[Unit]> {
        return Unit.query(on: req).all()
    }

    func addUnitToDetachmentUnitRole(_ req: Request) throws -> Future<Detachment> {
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
    }

}
