import Vapor
import FluentPostgreSQL

final class WeaponController {

    // MARK: - Public Functions

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

    func addWeaponToModel(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)

        let requestFuture = try req.content.decode(AddWeaponToModelRequest.self)
        let unitFuture = Unit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing)
        let modelFuture = Model.find(modelId, on: req).unwrap(or: RoasterHammerError.modelIsMissing)
        let weaponFuture = Weapon.find(weaponId, on: req).unwrap(or: RoasterHammerError.weaponIsMissing)

        return flatMap(unitFuture, modelFuture, weaponFuture, requestFuture, { (unit, model, weapon, request) in
            return model.weapons.attach(weapon, on: req)
                .flatMap(to: ModelWeapon.self, { modelWeapon in
                    modelWeapon.minQuantity = request.minQuantity
                    modelWeapon.maxQuantity = request.maxQuantity
                    return modelWeapon.update(on: req)
                })
                .flatMap(to: UnitResponse.self, { _ in
                    let unitController = UnitController()
                    return try unitController.unitResponse(forUnit: unit, conn: req)
                })
        })
    }

    // MARK: - Utils Functions

    func weaponResponse(forWeapon weapon: Weapon, model: Model, conn: DatabaseConnectable) throws -> Future<WeaponResponse> {
        let unitWeapon = try model.weapons
            .pivots(on: conn)
            .filter(\.weaponId == weapon.requireID())
            .first()
            .unwrap(or: RoasterHammerError.weaponIsMissing)

        return unitWeapon.map(to: WeaponResponse.self, { unitWeapon in
            return try WeaponResponse(weapon: weapon,
                                      minQuantity: unitWeapon.minQuantity,
                                      maxQuantity: unitWeapon.maxQuantity)
        })
    }

}
