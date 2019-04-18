import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

public struct CreateWeaponBucketRequest: Content {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

final class WeaponBucketController {

    // MARK: - Public Functions

    func createWeaponBucket(_ req: Request) throws -> Future<WeaponBucket> {
        return try req.content.decode(CreateWeaponBucketRequest.self)
            .flatMap(to: WeaponBucket.self, { request in
                return self.createWeaponBucket(request: request, conn: req)
            })
    }

    func assignModelToWeaponBucket(_ req: Request) throws -> Future<WeaponBucket> {
        let modelId = try req.parameters.next(Int.self)
        let weaponBucketId = try req.parameters.next(Int.self)

        let modelFuture = UnitController().getModel(byID: modelId, conn: req)
        let weaponBucketFuture = getWeaponBucketById(weaponBucketId, conn: req)

        return flatMap(to: WeaponBucket.self, modelFuture, weaponBucketFuture, { (model, weaponBucket) in
            return try self.assignWeaponBucketToModel(weaponBucket: weaponBucket, model: model, conn: req)
        })
    }

    func assignWeaponToWeaponBucket(_ req: Request) throws -> Future<WeaponBucket> {
        let weaponId = try req.parameters.next(Int.self)
        let weaponBucketId = try req.parameters.next(Int.self)

        let weaponFuture = WeaponController().getWeapon(byID: weaponId, conn: req)
        let weaponBucketFuture = getWeaponBucketById(weaponBucketId, conn: req)

        return flatMap(to: WeaponBucket.self, weaponFuture, weaponBucketFuture, { (weapon, weaponBucket) in
            return try self.assignWeaponToWeaponBucket(weaponBucket: weaponBucket, weapon: weapon, conn: req)
        })
    }

    // MARK: - Utils Functions

    func createWeaponBucket(request: CreateWeaponBucketRequest,
                            conn: DatabaseConnectable) -> Future<WeaponBucket> {
        return WeaponBucket(name: request.name).save(on: conn)
    }

    func getWeaponBucketById(_ weaponBucketId: Int, conn: DatabaseConnectable) -> Future<WeaponBucket> {
        return WeaponBucket.find(weaponBucketId, on: conn)
            .unwrap(or: RoasterHammerError.weaponBucketIsMissing)
    }

    func assignWeaponBucketToModel(weaponBucket: WeaponBucket,
                                   model: Model,
                                   conn: DatabaseConnectable) throws -> Future<WeaponBucket> {
        return weaponBucket.models.attach(model, on: conn)
            .flatMap(to: WeaponBucket.self, { _ in
                return try self.getWeaponBucketById(weaponBucket.requireID(), conn: conn)
            })
    }

    func assignWeaponToWeaponBucket(weaponBucket: WeaponBucket,
                                    weapon: Weapon,
                                    conn: DatabaseConnectable) throws -> Future<WeaponBucket> {
        return weaponBucket.weapons.attach(weapon, on: conn)
            .flatMap(to: WeaponBucket.self, { _ in
                return try self.getWeaponBucketById(weaponBucket.requireID(), conn: conn)
            })
    }
}
