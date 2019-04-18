@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

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
        XCTAssertEqual(weapon.ability, request.ability)
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
        XCTAssertEqual(weapon.ability, getWeapon.ability)
    }

    func testEditWeapon() throws {
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let editWeaponRequest = CreateWeaponData(name: "New Name",
                                                 range: "New Range",
                                                 type: "New Type",
                                                 strength: "New S",
                                                 armorPiercing: "New AP",
                                                 damage: "New D",
                                                 cost: "100",
                                                 ability: "New ability")
        let editedWeapon = try app.getResponse(to: "weapons/\(weapon.requireID())",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: editWeaponRequest,
            decodeTo: Weapon.self)
        XCTAssertEqual(editedWeapon.name, editWeaponRequest.name)
        XCTAssertEqual(editedWeapon.range, editWeaponRequest.range)
        XCTAssertEqual(editedWeapon.type, editWeaponRequest.type)
        XCTAssertEqual(editedWeapon.strength, editWeaponRequest.strength)
        XCTAssertEqual(editedWeapon.armorPiercing, editWeaponRequest.armorPiercing)
        XCTAssertEqual(editedWeapon.damage, editWeaponRequest.damage)
        XCTAssertEqual(editedWeapon.cost, editWeaponRequest.cost.intValue)
        XCTAssertEqual(editedWeapon.ability, editWeaponRequest.ability)
    }

    func testDeleteWeapon() throws {
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let weaponId = try weapon.requireID()
        _ = try app.sendRequest(to: "weapons/\(weaponId)", method: .DELETE)

        do {
            _ = try app.getResponse(to: "weapons/\(weaponId)", decodeTo: Weapon.self)
            XCTFail("Should have received a missing army error")
        } catch {
            print(error)
            XCTAssertNotNil(error)
        }
    }

}
