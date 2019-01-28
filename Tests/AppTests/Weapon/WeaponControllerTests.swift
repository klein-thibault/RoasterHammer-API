@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class WeaponControllerTests: BaseTests {

    func testCreateWeapon() throws {
        let (request, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        XCTAssertNotNil(weapon.id)
        XCTAssertEqual(weapon.name, request.name)
        XCTAssertEqual(weapon.range, request.range)
        XCTAssertEqual(weapon.type, request.type)
        XCTAssertEqual(weapon.strength, request.strength)
        XCTAssertEqual(weapon.armorPiercing, request.armorPiercing)
        XCTAssertEqual(weapon.damage, request.damage)
        XCTAssertEqual(weapon.cost, request.cost)
    }

    func testGetAllWeapons() throws {
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let allWeapons = try app.getResponse(to: "weapons", decodeTo: [Weapon].self)
        XCTAssertEqual(allWeapons.count, 1)
        XCTAssertEqual(allWeapons[0].id!, weapon.id!)
    }

    func testGetWeapon() throws {
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let getWeapon = try app.getResponse(to: "weapons/\(weapon.id!)", decodeTo: Weapon.self)
        XCTAssertEqual(weapon.name, getWeapon.name)
        XCTAssertEqual(weapon.range, getWeapon.range)
        XCTAssertEqual(weapon.type, getWeapon.type)
        XCTAssertEqual(weapon.strength, getWeapon.strength)
        XCTAssertEqual(weapon.armorPiercing, getWeapon.armorPiercing)
        XCTAssertEqual(weapon.damage, getWeapon.damage)
        XCTAssertEqual(weapon.cost, getWeapon.cost)
    }

    func testAttachWeaponToModel() throws {
        let (_, unit) = try UnitTestsUtils.createUnit(app: app)
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let model = unit.models[0]

        let addWeaponToUnitRequest = AddWeaponToModelRequest(minQuantity: 1, maxQuantity: 1)
        let unitWithWeapon = try app.getResponse(to: "units/\(unit.id)/models/\(model.id)/weapons/\(weapon.id!)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addWeaponToUnitRequest,
            decodeTo: UnitResponse.self)
        let modelWithWeapon = unitWithWeapon.models[0]

        XCTAssertEqual(modelWithWeapon.weapons.count, 1)
        XCTAssertEqual(modelWithWeapon.weapons[0].name, "Pistol")
        XCTAssertEqual(modelWithWeapon.weapons[0].range, "12\"")
        XCTAssertEqual(modelWithWeapon.weapons[0].type, "Pistol")
        XCTAssertEqual(modelWithWeapon.weapons[0].strength, "3")
        XCTAssertEqual(modelWithWeapon.weapons[0].armorPiercing, "0")
        XCTAssertEqual(modelWithWeapon.weapons[0].damage, "1")
        XCTAssertEqual(modelWithWeapon.weapons[0].cost, 15)
        XCTAssertEqual(modelWithWeapon.weapons[0].minQuantity, 1)
        XCTAssertEqual(modelWithWeapon.weapons[0].maxQuantity, 1)
    }

}
