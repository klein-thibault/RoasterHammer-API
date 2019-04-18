@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class WeaponBucketTestUtils {
    static func createWeaponBucket(app: Application) throws -> (request: CreateWeaponBucketRequest, response: WeaponBucket) {
        let request = CreateWeaponBucketRequest(name: "Pistol Options")
        let weaponBucket = try app.getResponse(to: "weapon-buckets",
                                               method: .POST,
                                               headers: ["Content-Type": "application/json"],
                                               data: request,
                                               decodeTo: WeaponBucket.self)

        return (request, weaponBucket)
    }
}
