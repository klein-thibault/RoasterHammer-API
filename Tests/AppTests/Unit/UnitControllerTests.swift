@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class UnitControllerTests: BaseTests {

    func testCreateUnit() throws {
        let characteristics = CharacteristicsRequest(movement: "6\"",
                                              weaponSkill: "2+",
                                              balisticSkill: "2+",
                                              strength: "5",
                                              toughness: "4",
                                              wounds: "6",
                                              attacks: "5",
                                              leadership: "9",
                                              save: "3+")
        let request = CreateUnitRequest(name: "Kharn", cost: 120, characteristics: characteristics)

        let unit = try app.getResponse(to: "units",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: request,
                                       decodeTo: UnitResponse.self)
        let unitCharacteristics = unit.characteristics

        XCTAssertNotNil(unit.id)
        XCTAssertEqual(unit.name, request.name)
        XCTAssertEqual(unit.cost, request.cost)
        XCTAssertEqual(unitCharacteristics.movement, request.characteristics.movement)
        XCTAssertEqual(unitCharacteristics.weaponSkill, request.characteristics.weaponSkill)
        XCTAssertEqual(unitCharacteristics.balisticSkill, request.characteristics.balisticSkill)
        XCTAssertEqual(unitCharacteristics.strength, request.characteristics.strength)
        XCTAssertEqual(unitCharacteristics.toughness, request.characteristics.toughness)
        XCTAssertEqual(unitCharacteristics.wounds, request.characteristics.wounds)
        XCTAssertEqual(unitCharacteristics.attacks, request.characteristics.attacks)
        XCTAssertEqual(unitCharacteristics.leadership, request.characteristics.leadership)
        XCTAssertEqual(unitCharacteristics.save, request.characteristics.save)
    }

    func testGettingAllUnits() throws {
        let characteristics = CharacteristicsRequest(movement: "6\"",
                                                     weaponSkill: "2+",
                                                     balisticSkill: "2+",
                                                     strength: "5",
                                                     toughness: "4",
                                                     wounds: "6",
                                                     attacks: "5",
                                                     leadership: "9",
                                                     save: "3+")
        let request = CreateUnitRequest(name: "Kharn", cost: 120, characteristics: characteristics)
        let unit = try app.getResponse(to: "units",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: request,
                                       decodeTo: UnitResponse.self)
        let units = try app.getResponse(to: "units", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(units[0].id, unit.id)
    }

    func testAddUnitToDetachment() throws {
        let user = try app.createAndLogUser()

        let createArmyRequest = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createArmyRequest,
                                       decodeTo: Army.self)

        let createDetachmentRequest = CreateDetachmentRequest(name: "Patrol", commandPoints: 0, armyId: army.id!)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: createDetachmentRequest,
                                             decodeTo: Detachment.self)
        let unitRoles = try detachment.roles.query(on: conn).all().wait()
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

        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id!)/roles/\(unitRoles[0].id!)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let updatedDetachmentRole = updatedDetachment.roles
        let addedUnit = updatedDetachmentRole[0].units
        let addedUnitCharacteristics = addedUnit[0].characteristics
        XCTAssertEqual(addedUnit[0].name, unit.name)
        XCTAssertEqual(addedUnit[0].cost, unit.cost)
        XCTAssertEqual(addedUnitCharacteristics.movement, createUnitRequest.characteristics.movement)
        XCTAssertEqual(addedUnitCharacteristics.weaponSkill, createUnitRequest.characteristics.weaponSkill)
        XCTAssertEqual(addedUnitCharacteristics.balisticSkill, createUnitRequest.characteristics.balisticSkill)
        XCTAssertEqual(addedUnitCharacteristics.strength, createUnitRequest.characteristics.strength)
        XCTAssertEqual(addedUnitCharacteristics.toughness, createUnitRequest.characteristics.toughness)
        XCTAssertEqual(addedUnitCharacteristics.wounds, createUnitRequest.characteristics.wounds)
        XCTAssertEqual(addedUnitCharacteristics.attacks, createUnitRequest.characteristics.attacks)
        XCTAssertEqual(addedUnitCharacteristics.leadership, createUnitRequest.characteristics.leadership)
        XCTAssertEqual(addedUnitCharacteristics.save, createUnitRequest.characteristics.save)
    }

}
