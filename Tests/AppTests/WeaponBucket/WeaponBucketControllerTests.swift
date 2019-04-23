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
        XCTAssertEqual(request.minWeaponQuantity, weaponBucket.minWeaponQuantity)
        XCTAssertEqual(request.maxWeaponQuantity, weaponBucket.maxWeaponQuantity)
    }

    func testAssignModelToWeaponBucket() throws {
        let user = try app.createAndLogUser()
        let (_, weaponBucket) = try WeaponBucketTestUtils.createWeaponBucket(app: app)
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        let model = unit.models[0]

        let _ = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/models/\(model.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucketResponse.self)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let updatedDetachmentRole = updatedDetachment.roles
        let addedUnit = updatedDetachmentRole[0].units
        let updatedModel = addedUnit[0].unit.models[0]


        XCTAssertTrue(updatedModel.weaponBuckets.count == 1)
    }

    func testAssignWeaponToWeaponBucket() throws {
        let (_, weaponBucket) = try WeaponBucketTestUtils.createWeaponBucket(app: app)
        let (_, weapon) = try WeaponTestsUtils.createPistolWeapon(app: app)

        let updatedWeaponBucket = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/weapons/\(weapon.requireID())",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucketResponse.self)

        XCTAssertTrue(updatedWeaponBucket.weapons.count == 1)
    }

    func testAttachWeaponToModel() throws {
        let user = try app.createAndLogUser()
        let (_, weaponBucket) = try WeaponBucketTestUtils.createWeaponBucket(app: app)
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createPistolWeapon(app: app)
        let model = unit.models[0]

        let weaponBucketWithModel = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/models/\(model.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucketResponse.self)
        let _ = try app.getResponse(to: "weapon-buckets/\(weaponBucketWithModel.id)/weapons/\(weapon.requireID())",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucketResponse.self)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let updatedDetachmentRole = updatedDetachment.roles
        let addedUnit = updatedDetachmentRole[0].units
        let updatedModel = addedUnit[0].unit.models[0]

        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons.count, 1)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].name, weapon.name)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].range, weapon.range)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].type, weapon.type)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].strength, weapon.strength)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].armorPiercing, weapon.armorPiercing)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].damage, weapon.damage)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].cost, weapon.cost)
        XCTAssertEqual(updatedModel.weaponBuckets[0].weapons[0].ability, weapon.ability)
    }

}
