import Vapor
import FluentPostgreSQL

final class WeaponController {

    // MARK: - Public Functions

    func createWeapon(_ req: Request) throws -> Future<Weapon> {
        return try req.content.decode(CreateWeaponRequest.self)
            .flatMap(to: Weapon.self, { request in
                return self.createWeapon(request: request, conn: req)
            })
    }

    func getAllWeapons(_ req: Request) throws -> Future<[Weapon]> {
        return getAllWeapons(conn: req)
    }

    func getWeaponById(_ req: Request) throws -> Future<Weapon> {
        let weaponId = try req.parameters.next(Int.self)
        return getWeapon(byID: weaponId, conn: req)
    }

    func addWeaponToModel(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)

        let requestFuture = try req.content.decode(AddWeaponToModelRequest.self)
        let unitFuture = Unit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let modelFuture = Model.find(modelId, on: req).unwrap(or: RoasterHammerError.modelIsMissing.error())
        let weaponFuture = Weapon.find(weaponId, on: req).unwrap(or: RoasterHammerError.weaponIsMissing.error())

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

    func editWeapon(_ req: Request) throws -> Future<Weapon> {
        let weaponId = try req.parameters.next(Int.self)

        return try req.content.decode(CreateWeaponData.self)
            .flatMap(to: Weapon.self, { request in
                return self.editWeapon(weaponId: weaponId, request: request, conn: req)
            })
    }

    func deleteWeapon(_ req: Request) throws -> Future<HTTPStatus> {
        let weaponId = try req.parameters.next(Int.self)
        return deleteWeapon(weaponId: weaponId, conn: req)
    }

    // MARK: - Utils Functions

    func weaponResponse(forWeapon weapon: Weapon,
                        model: Model,
                        conn: DatabaseConnectable) throws -> Future<WeaponResponse> {
        let unitWeapon = try model.weapons
            .pivots(on: conn)
            .filter(\.weaponId == weapon.requireID())
            .first()
            .unwrap(or: RoasterHammerError.weaponIsMissing.error())

        return unitWeapon.map(to: WeaponResponse.self, { unitWeapon in
            return try WeaponResponse(weapon: weapon,
                                      minQuantity: unitWeapon.minQuantity,
                                      maxQuantity: unitWeapon.maxQuantity)
        })
    }

    func getAllWeapons(conn: DatabaseConnectable) -> Future<[Weapon]> {
        return Weapon.query(on: conn).all()
    }

    func getWeapon(byID id: Int, conn: DatabaseConnectable) -> Future<Weapon> {
        return Weapon.find(id, on: conn).unwrap(or: RoasterHammerError.weaponIsMissing.error())
    }

    func createWeapon(request: CreateWeaponRequest, conn: DatabaseConnectable) -> Future<Weapon> {
        return Weapon(name: request.name,
                      range: request.range,
                      type: request.type,
                      strength: request.strength,
                      armorPiercing: request.armorPiercing,
                      damage: request.damage,
                      cost: request.cost,
                      ability: request.ability)
            .save(on: conn)
    }

    func editWeapon(weaponId: Int, request: CreateWeaponData, conn: DatabaseConnectable) -> Future<Weapon> {
        return Weapon.find(weaponId, on: conn)
        .unwrap(or: RoasterHammerError.weaponIsMissing.error())
            .flatMap(to: Weapon.self, { weapon in
                guard let cost = request.cost.intValue else {
                    throw Abort(.badRequest)
                }

                weapon.name = request.name
                weapon.range = request.range
                weapon.type = request.type
                weapon.strength = request.strength
                weapon.armorPiercing = request.armorPiercing
                weapon.damage = request.damage
                weapon.cost = cost
                weapon.ability = request.ability

                return weapon.save(on: conn)
            })
    }

    func deleteWeapon(weaponId: Int, conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return Weapon.find(weaponId, on: conn)
            .unwrap(or: RoasterHammerError.weaponIsMissing.error())
            .delete(on: conn)
            .transform(to: HTTPStatus.ok)
    }

}
