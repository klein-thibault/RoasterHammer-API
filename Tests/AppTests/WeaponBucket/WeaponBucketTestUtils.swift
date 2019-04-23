@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class WeaponBucketTestUtils {
    static func createWeaponBucket(app: Application,
                                   minWeaponQuantity: Int = 1,
                                   maxWeaponQuantity: Int = 1) throws -> (request: CreateWeaponBucketRequest, response: WeaponBucketResponse) {
        let request = CreateWeaponBucketRequest(name: "Pistol Options",
                                                minWeaponQuantity: minWeaponQuantity,
                                                maxWeaponQuantity: maxWeaponQuantity)
        let weaponBucket = try app.getResponse(to: "weapon-buckets",
                                               method: .POST,
                                               headers: ["Content-Type": "application/json"],
                                               data: request,
                                               decodeTo: WeaponBucketResponse.self)

        return (request, weaponBucket)
    }

    static func assignWeaponToModel(weaponId: Int,
                                    modelId: Int,
                                    app: Application,
                                    minWeaponQuantity: Int = 1,
                                    maxWeaponQuantity: Int = 1) throws -> WeaponBucketResponse {
        let request = CreateWeaponBucketRequest(name: "Pistol Options",
                                                minWeaponQuantity: minWeaponQuantity,
                                                maxWeaponQuantity: maxWeaponQuantity)
        let weaponBucket = try app.getResponse(to: "weapon-buckets",
                                               method: .POST,
                                               headers: ["Content-Type": "application/json"],
                                               data: request,
                                               decodeTo: WeaponBucket.self)
        let _ = try app.getResponse(to: "weapon-buckets/\(weaponBucket.requireID())/weapons/\(weaponId)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucket.self)

        return try app.getResponse(to: "weapon-buckets/\(weaponBucket.requireID())/models/\(modelId)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucketResponse.self)
    }
}
