import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteWeaponBucketController {

    // MARK: - Public Functions

    func weaponBucketsHandler(_ req: Request) throws -> Future<View> {
        let unitId = try req.parameters.next(Int.self)
        let unitController = UnitController()

        return unitController.getUnit(byID: unitId, conn: req)
            .flatMap(to: View.self, { unit in
                let context = WeaponBucketsContext(title: "Weapon Buckets", unit: unit)
                return try req.view().render("unitWeaponBucket", context)
            })
    }

    func createWeaponBucketPostHandler(_ req: Request,
                                       createWeaponBucketRequest: CreateWeaponBucketData) throws -> Future<Response> {
        let requests = makeCreateWeaponBucketRequest(forWeaponBucketData: createWeaponBucketRequest.weaponBuckets)

        return try createAndAssignWeaponBuckets(requests: requests, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/units"))
    }

    func editWeaponBucketHandler(_ req: Request) throws -> Future<View> {
        let weaponBucketId = try req.parameters.next(Int.self)

        let weaponBucketFuture = WeaponBucketController().getWeaponBucket(byID: weaponBucketId, conn: req)
        let weaponsFuture = try WeaponController().getAllWeapons(req)

        return flatMap(to: View.self, weaponBucketFuture, weaponsFuture, { (weaponBucket, weapons) in
            let context = EditWeaponBucketContext(title: "Edit Weapon Bucket", weaponBucket: weaponBucket, weapons: weapons)
            return try req.view().render("weaponBucketWeapons", context)
        })
    }

    func editWeaponBucketPostHandler(_ req: Request,
                                     editWeaponBucketRequest: EditWeaponBucketData) throws -> Future<Response> {
        let weaponBucketId = try req.parameters.next(Int.self)
        let weaponIds = editWeaponBucketRequest.weaponCheckbox.keys.compactMap { $0.intValue }

        return assignWeaponsToWeaponBucket(weaponBucketId: weaponBucketId, weaponIds: weaponIds, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/units"))
    }

    // MARK: - Private Functions

    // Structure follows [modelId: [request1, request2]]
    private func makeCreateWeaponBucketRequest(forWeaponBucketData weaponBucketData: DynamicFormData) -> [Int: [CreateWeaponBucketRequest]] {
        var weaponBuckets: [Int: [CreateWeaponBucketRequest]] = [:]

        for weaponBucketDictionary in weaponBucketData.values {
            if let weaponBucketName = weaponBucketDictionary["name"],
                let weaponBucketMinWeaponQuantity = weaponBucketDictionary["minWeaponQuantity"]?.intValue,
                let weaponBucketMaxWeaponQuantity = weaponBucketDictionary["maxWeaponQuantity"]?.intValue,
                let modelId = weaponBucketDictionary["modelId"]?.intValue {
                let weaponBucketRequest = CreateWeaponBucketRequest(name: weaponBucketName,
                                                                    minWeaponQuantity: weaponBucketMinWeaponQuantity,
                                                                    maxWeaponQuantity: weaponBucketMaxWeaponQuantity)

                if var requestArray = weaponBuckets[modelId] {
                    requestArray.append(weaponBucketRequest)
                    weaponBuckets[modelId] = requestArray
                } else {
                    weaponBuckets[modelId] = [weaponBucketRequest]
                }
            }
        }
        return weaponBuckets
    }

    private func createAndAssignWeaponBuckets(requests: [Int : [CreateWeaponBucketRequest]],
                                              conn: DatabaseConnectable) throws -> Future<[[WeaponBucket]]> {
        let weaponBucketController = WeaponBucketController()

        return requests.keys.map({ modelId in
            return Model
                .find(modelId, on: conn)
                .unwrap(or: RoasterHammerError.modelIsMissing.error())
                .flatMap(to: [WeaponBucket].self, { model in
                    var createWeaponBucketFutures: [Future<WeaponBucket>] = []
                    if let createWeaponBucketRequests = requests[modelId] {
                        createWeaponBucketFutures = createWeaponBucketRequests.map({ weaponBucketController.createWeaponBucket(request: $0, conn: conn)} )
                    }

                    return createWeaponBucketFutures
                        .flatten(on: conn)
                        .flatMap(to: [WeaponBucket].self) { weaponBuckets in
                            let assignModelToWeaponBucketFutures: [Future<WeaponBucket>] = try weaponBuckets.map {
                                try weaponBucketController.assignWeaponBucketToModel(weaponBucket: $0, model: model, conn: conn)
                            }
                            return assignModelToWeaponBucketFutures.flatten(on: conn)
                    }
                })
        })
            .flatten(on: conn)
    }

    private func assignWeaponsToWeaponBucket(weaponBucketId: Int,
                                             weaponIds: [Int],
                                             conn: DatabaseConnectable) -> Future<[WeaponBucketWeapon]> {
        let weaponBucketController = WeaponBucketController()
        let weaponController = WeaponController()
        let weaponBucketFuture = weaponBucketController.getWeaponBucket(byID: weaponBucketId, conn: conn)
        let weaponsFuture = weaponIds.map { weaponController.getWeapon(byID: $0, conn: conn) }.flatten(on: conn)

        return flatMap(to: [WeaponBucketWeapon].self, weaponBucketFuture, weaponsFuture, { (weaponBucket, weapons) in
            return weapons.map { weaponBucket.weapons.attach($0, on: conn) }.flatten(on: conn)
        })
    }
}
