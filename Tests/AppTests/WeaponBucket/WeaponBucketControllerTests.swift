@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class WeaponBucketControllerTests: BaseTests {

    func testCreateWeaponBucket() throws {
        let (request, weaponBucket) = try WeaponBucketTestUtils.createWeaponBucket(app: app)
        XCTAssertNotNil(weaponBucket.id)
        XCTAssertEqual(request.name, weaponBucket.name)
    }

    func testAssignModelToWeaponBucket() throws {
        let (_, weaponBucket) = try WeaponBucketTestUtils.createWeaponBucket(app: app)
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createTroopUnit(armyId: army.requireID(), app: app)

        guard let model = unit.models.first else {
            assertionFailure("The model could not be found")
            return
        }

        let updatedWeaponBucket = try app.getResponse(to: "weapon-buckets/\(weaponBucket.requireID())/models/\(model.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucket.self)
        let weaponBucketModels = try updatedWeaponBucket.models.query(on: conn).all().wait()

        XCTAssertTrue(weaponBucketModels.count == 1)
    }

    func testAssignWeaponToWeaponBucket() throws {
        let (_, weaponBucket) = try WeaponBucketTestUtils.createWeaponBucket(app: app)
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)

        let updatedWeaponBucket = try app.getResponse(to: "weapon-buckets/\(weaponBucket.requireID())/weapons/\(weapon.requireID())",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucket.self)
        let weaponBucketWeapons = try updatedWeaponBucket.weapons.query(on: conn).all().wait()

        XCTAssertTrue(weaponBucketWeapons.count == 1)
    }

}
