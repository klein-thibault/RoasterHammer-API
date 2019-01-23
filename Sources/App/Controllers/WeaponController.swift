import Vapor
import FluentPostgreSQL

final class WeaponController {

    func createWeapon(_ req: Request) throws -> Future<Weapon> {
        return try req.content.decode(CreateWeaponRequest.self)
            .flatMap(to: Weapon.self, { request in
                return Weapon(name: request.name,
                              range: request.range,
                              type: request.type,
                              strength: request.strength,
                              armorPiercing: request.armorPiercing,
                              damage: request.damage,
                              cost: request.cost)
                .save(on: req)
            })
    }

    func getAllWeapons(_ req: Request) throws -> Future<[Weapon]> {
        return Weapon.query(on: req).all()
    }

    func getWeaponById(_ req: Request) throws -> Future<Weapon> {
        let weaponId = try req.parameters.next(Int.self)
        return Weapon.find(weaponId, on: req).unwrap(or: RoasterHammerError.weaponIsMissing)
    }

    func attachWeaponToUnit(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)

        let unitFuture = Unit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing)
        let weaponFuture = Weapon.find(weaponId, on: req).unwrap(or: RoasterHammerError.weaponIsMissing)

        return flatMap(unitFuture, weaponFuture, { (unit, weapon) -> EventLoopFuture<UnitResponse> in
            return unit.weapons.attach(weapon, on: req)
                .flatMap(to: UnitResponse.self, { _ in
                    let unitController = UnitController()
                    return try unitController.unitResponse(forUnit: unit, conn: req)
                })
        })
    }

//    func updateUnitWeaponSelection(_ req: Request) throws -> Future<UnitResponse> {
//        let unitId = try req.parameters.next(Int.self)
//        let weaponId = try req.parameters.next(Int.self)
//
//        return try req.content.decode(UpdateUnitWeaponSelectionRequest.self)
//            .flatMap(to: UnitResponse.self, { request in
//                return UnitWeapon.query(on: req).filter(\.unitId == unitId).all().then({ unitWeapons in
//                })
//        })
//    }

}
