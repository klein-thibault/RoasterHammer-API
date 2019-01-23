@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class WeaponControllerTests: BaseTests {

    func createWeapon(request: CreateWeaponRequest) throws -> Weapon {
        let weapon = try app.getResponse(to: "weapons",
                                         method: .POST,
                                         headers: ["Content-Type": "application/json"],
                                         data: request,
                                         decodeTo: Weapon.self)

        return weapon
    }

    func testCreateWeapon() throws {
        let request = CreateWeaponRequest(name: "Pistol",
                                          range: "12\"",
                                          type: "Pistol",
                                          strength: "3",
                                          armorPiercing: "0",
                                          damage: "1",
                                          cost: 15)
        let weapon = try createWeapon(request: request)

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
        let request = CreateWeaponRequest(name: "Pistol",
                                          range: "12\"",
                                          type: "Pistol",
                                          strength: "3",
                                          armorPiercing: "0",
                                          damage: "1",
                                          cost: 15)
        let weapon = try createWeapon(request: request)
        let allWeapons = try app.getResponse(to: "weapons", decodeTo: [Weapon].self)

        XCTAssertEqual(allWeapons.count, 1)
        XCTAssertEqual(allWeapons[0].id!, weapon.id!)
    }

    func testGetWeapon() throws {
        let request = CreateWeaponRequest(name: "Pistol",
                                          range: "12\"",
                                          type: "Pistol",
                                          strength: "3",
                                          armorPiercing: "0",
                                          damage: "1",
                                          cost: 15)
        let weapon = try createWeapon(request: request)
        let getWeapon = try app.getResponse(to: "weapons/\(weapon.id!)", decodeTo: Weapon.self)
        XCTAssertEqual(weapon.name, getWeapon.name)
        XCTAssertEqual(weapon.range, getWeapon.range)
        XCTAssertEqual(weapon.type, getWeapon.type)
        XCTAssertEqual(weapon.strength, getWeapon.strength)
        XCTAssertEqual(weapon.armorPiercing, getWeapon.armorPiercing)
        XCTAssertEqual(weapon.damage, getWeapon.damage)
        XCTAssertEqual(weapon.cost, getWeapon.cost)
    }

    func testAttachWeaponToUnit() throws {
        let characteristics = CharacteristicsRequest(movement: "6\"",
                                                     weaponSkill: "2+",
                                                     balisticSkill: "2+",
                                                     strength: "5",
                                                     toughness: "4",
                                                     wounds: "6",
                                                     attacks: "5",
                                                     leadership: "9",
                                                     save: "3+")
        let createUnitRequest = CreateUnitRequest(name: "Kharn", cost: 120, characteristics: characteristics)
        let unit = try app.getResponse(to: "units",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createUnitRequest,
                                       decodeTo: UnitResponse.self)

        let createWeaponRequest = CreateWeaponRequest(name: "Pistol",
                                                      range: "12\"",
                                                      type: "Pistol",
                                                      strength: "3",
                                                      armorPiercing: "0",
                                                      damage: "1",
                                                      cost: 15)
        let weapon = try createWeapon(request: createWeaponRequest)

        let unitWithWeapon = try app.getResponse(to: "units/\(unit.id)/weapons/\(weapon.id!)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: UnitResponse.self)

        XCTAssertEqual(unitWithWeapon.weapons.count, 1)
        XCTAssertEqual(unitWithWeapon.selectedWeapons.count, 0)
        XCTAssertEqual(unitWithWeapon.weapons[0].name, "Pistol")
        XCTAssertEqual(unitWithWeapon.weapons[0].range, "12\"")
        XCTAssertEqual(unitWithWeapon.weapons[0].type, "Pistol")
        XCTAssertEqual(unitWithWeapon.weapons[0].strength, "3")
        XCTAssertEqual(unitWithWeapon.weapons[0].armorPiercing, "0")
        XCTAssertEqual(unitWithWeapon.weapons[0].damage, "1")
        XCTAssertEqual(unitWithWeapon.weapons[0].cost, 15)
    }

}
