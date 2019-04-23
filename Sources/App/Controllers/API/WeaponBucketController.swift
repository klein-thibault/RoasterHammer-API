import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class WeaponBucketController {

    // MARK: - Public Functions

    func createWeaponBucket(_ req: Request) throws -> Future<WeaponBucketResponse> {
        return try req.content.decode(CreateWeaponBucketRequest.self)
            .flatMap(to: WeaponBucket.self, { request in
                return self.createWeaponBucket(request: request, conn: req)
            })
            .flatMap(to: WeaponBucketResponse.self, { weaponBucket in
                return try self.weaponBucketResponse(forWeaponBucket: weaponBucket,
                                                     conn: req)
            })
    }

    func getWeaponBucket(_ req: Request) throws -> Future<WeaponBucketResponse> {
        let weaponBucketId = try req.parameters.next(Int.self)

        return getWeaponBucket(byID: weaponBucketId, conn: req)
            .flatMap(to: WeaponBucketResponse.self, { weaponBucket in
                return try self.weaponBucketResponse(forWeaponBucket: weaponBucket,
                                                     conn: req)
            })
    }

    func assignModelToWeaponBucket(_ req: Request) throws -> Future<WeaponBucketResponse> {
        let modelId = try req.parameters.next(Int.self)
        let weaponBucketId = try req.parameters.next(Int.self)

        let modelFuture = UnitDatabaseQueries().getModel(byID: modelId, conn: req)
        let weaponBucketFuture = getWeaponBucket(byID: weaponBucketId, conn: req)

        return flatMap(to: WeaponBucket.self, modelFuture, weaponBucketFuture, { (model, weaponBucket) in
            return try self.assignWeaponBucketToModel(weaponBucket: weaponBucket, model: model, conn: req)
        })
            .flatMap(to: WeaponBucketResponse.self, { weaponBucket in
                return try self.weaponBucketResponse(forWeaponBucket: weaponBucket,
                                                     conn: req)
            })
    }

    func assignWeaponToWeaponBucket(_ req: Request) throws -> Future<WeaponBucketResponse> {
        let weaponBucketId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)

        let weaponFuture = WeaponController().getWeapon(byID: weaponId, conn: req)
        let weaponBucketFuture = getWeaponBucket(byID: weaponBucketId, conn: req)

        return flatMap(to: WeaponBucket.self, weaponFuture, weaponBucketFuture, { (weapon, weaponBucket) in
            return try self.assignWeaponToWeaponBucket(weaponBucket: weaponBucket, weapon: weapon, conn: req)
        })
            .flatMap(to: WeaponBucketResponse.self, { weaponBucket in
                return try self.weaponBucketResponse(forWeaponBucket: weaponBucket,
                                                     conn: req)
            })
    }

    // MARK: - Utils Functions

    func weaponBucketResponse(forWeaponBucket weaponBucket: WeaponBucket,
                              conn: DatabaseConnectable) throws -> Future<WeaponBucketResponse> {
        return try weaponBucket.weapons.query(on: conn).all()
            .map(to: [WeaponResponse].self, { (weapons) in
                let weaponController = WeaponController()
                return try weapons.map { try weaponController.weaponResponse(forWeapon: $0) }
            })
            .map(to: WeaponBucketResponse.self, { (weapons) in
                let weaponBucketDTO = try WeaponBucketDTO(id: weaponBucket.requireID(),
                                                          name: weaponBucket.name,
                                                          minWeaponQuantity: weaponBucket.minWeaponQuantity,
                                                          maxWeaponQuantity: weaponBucket.maxWeaponQuantity)
                return WeaponBucketResponse(weaponBucket: weaponBucketDTO, weapons: weapons)
            })
    }

    func createWeaponBucket(request: CreateWeaponBucketRequest,
                            conn: DatabaseConnectable) -> Future<WeaponBucket> {
        return WeaponBucket(name: request.name,
                            minWeaponQuantity: request.minWeaponQuantity,
                            maxWeaponQuantity: request.maxWeaponQuantity)
            .save(on: conn)
    }

    func getWeaponBucket(byID weaponBucketId: Int, conn: DatabaseConnectable) -> Future<WeaponBucket> {
        return WeaponBucket.find(weaponBucketId, on: conn)
            .unwrap(or: RoasterHammerError.weaponBucketIsMissing)
    }

    func assignWeaponBucketToModel(weaponBucket: WeaponBucket,
                                   model: Model,
                                   conn: DatabaseConnectable) throws -> Future<WeaponBucket> {
        return weaponBucket.models.attach(model, on: conn)
            .flatMap(to: WeaponBucket.self, { _ in
                return try self.getWeaponBucket(byID: weaponBucket.requireID(), conn: conn)
            })
    }

    func assignWeaponToWeaponBucket(weaponBucket: WeaponBucket,
                                    weapon: Weapon,
                                    conn: DatabaseConnectable) throws -> Future<WeaponBucket> {
        return weaponBucket.weapons.attach(weapon, on: conn)
            .flatMap(to: WeaponBucket.self, { _ in
                return try self.getWeaponBucket(byID: weaponBucket.requireID(), conn: conn)
            })
    }

    func getWeaponBucketForModelId(model: Model, conn: DatabaseConnectable) throws -> Future<[WeaponBucket]> {
        return try model.weaponBuckets.query(on: conn).all()
    }
}
