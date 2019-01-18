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

}
