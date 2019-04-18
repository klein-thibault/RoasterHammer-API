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

        let updatedWeaponBucket = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/models/\(model.id)",
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

        let updatedWeaponBucket = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/weapons/\(weapon.requireID())",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucket.self)
        let weaponBucketWeapons = try updatedWeaponBucket.weapons.query(on: conn).all().wait()

        XCTAssertTrue(weaponBucketWeapons.count == 1)
    }

    func testGetWeaponBucketsForModel() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let model = unit.models[0]

        

//        let addWeaponToUnitRequest = AddWeaponToModelRequest(minQuantity: 1, maxQuantity: 1)
//        let unitWithWeapon = try app.getResponse(to: "units/\(unit.id)/models/\(model.id)/weapons/\(weapon.id!)",
//            method: .POST,
//            headers: ["Content-Type": "application/json"],
//            data: addWeaponToUnitRequest,
//            decodeTo: UnitResponse.self)
//        let modelWithWeapon = unitWithWeapon.models[0]
//
//        let modelWeapons = try app.getResponse(to: "/weapons/models/\(model.id)", decodeTo: [Weapon].self)
//
//        XCTAssertEqual(modelWithWeapon.weapons.count, modelWeapons.count)
//        XCTAssertEqual(modelWithWeapon.weapons[0].name, modelWeapons[0].name)
//        XCTAssertEqual(modelWithWeapon.weapons[0].range, modelWeapons[0].range)
//        XCTAssertEqual(modelWithWeapon.weapons[0].type, modelWeapons[0].type)
//        XCTAssertEqual(modelWithWeapon.weapons[0].strength, modelWeapons[0].strength)
//        XCTAssertEqual(modelWithWeapon.weapons[0].armorPiercing, modelWeapons[0].armorPiercing)
//        XCTAssertEqual(modelWithWeapon.weapons[0].damage, modelWeapons[0].damage)
//        XCTAssertEqual(modelWithWeapon.weapons[0].cost, modelWeapons[0].cost)
//        XCTAssertEqual(modelWithWeapon.weapons[0].ability, modelWeapons[0].ability)
    }

    func testAttachWeaponToModel() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let model = unit.models[0]

//        let addWeaponToUnitRequest = AddWeaponToModelRequest(minQuantity: 1, maxQuantity: 1)
//        let unitWithWeapon = try app.getResponse(to: "units/\(unit.id)/models/\(model.id)/weapons/\(weapon.id!)",
//            method: .POST,
//            headers: ["Content-Type": "application/json"],
//            data: addWeaponToUnitRequest,
//            decodeTo: UnitResponse.self)
//        let modelWithWeapon = unitWithWeapon.models[0]
//
//        XCTAssertEqual(modelWithWeapon.weapons.count, 1)
//        XCTAssertEqual(modelWithWeapon.weapons[0].name, "Pistol")
//        XCTAssertEqual(modelWithWeapon.weapons[0].range, "12\"")
//        XCTAssertEqual(modelWithWeapon.weapons[0].type, "Pistol")
//        XCTAssertEqual(modelWithWeapon.weapons[0].strength, "3")
//        XCTAssertEqual(modelWithWeapon.weapons[0].armorPiercing, "0")
//        XCTAssertEqual(modelWithWeapon.weapons[0].damage, "1")
//        XCTAssertEqual(modelWithWeapon.weapons[0].cost, 15)
//        XCTAssertEqual(modelWithWeapon.weapons[0].ability, "-")
//        XCTAssertEqual(modelWithWeapon.weapons[0].minQuantity, 1)
//        XCTAssertEqual(modelWithWeapon.weapons[0].maxQuantity, 1)
    }

}
