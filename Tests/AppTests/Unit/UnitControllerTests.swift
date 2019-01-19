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
                                       decodeTo: Unit.self)
        let unitCharacteristics = try unit.characteristics.query(on: conn).filter(\.unitId == unit.id!).first().wait()

        XCTAssertNotNil(unit.id)
        XCTAssertEqual(unit.name, request.name)
        XCTAssertEqual(unit.cost, request.cost)
        XCTAssertEqual(unitCharacteristics?.movement, request.characteristics.movement)
        XCTAssertEqual(unitCharacteristics?.weaponSkill, request.characteristics.weaponSkill)
        XCTAssertEqual(unitCharacteristics?.balisticSkill, request.characteristics.balisticSkill)
        XCTAssertEqual(unitCharacteristics?.strength, request.characteristics.strength)
        XCTAssertEqual(unitCharacteristics?.toughness, request.characteristics.toughness)
        XCTAssertEqual(unitCharacteristics?.wounds, request.characteristics.wounds)
        XCTAssertEqual(unitCharacteristics?.attacks, request.characteristics.attacks)
        XCTAssertEqual(unitCharacteristics?.leadership, request.characteristics.leadership)
        XCTAssertEqual(unitCharacteristics?.save, request.characteristics.save)
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
                                       decodeTo: Unit.self)
        // TODO: replace by the API call - got a type error for some reason
        let units = try Unit.query(on: conn).all().wait()

        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(units[0].id!, unit.id!)
    }

    func testAddUnitToDetachment() throws {
        let user = try app.createAndLogUser()
        let createDetachmentRequest = CreateDetachmentRequest(name: "Patrol", commandPoints: 0)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: createDetachmentRequest,
                                             decodeTo: DetachmentResponse.self)
        let unitRoles = detachment.roles
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
                                       decodeTo: Unit.self)

        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id!)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: Detachment.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let updatedDetachmentRole = try updatedDetachment.roles.query(on: conn).first().wait()
        let addedUnit = try updatedDetachmentRole?.units.query(on: conn).first().wait()
        let addedUnitCharacteristics = try addedUnit?.characteristics.query(on: conn).first().wait()
        XCTAssertEqual(addedUnit?.name, unit.name)
        XCTAssertEqual(addedUnit?.cost, unit.cost)
        XCTAssertEqual(addedUnitCharacteristics?.movement, createUnitRequest.characteristics.movement)
        XCTAssertEqual(addedUnitCharacteristics?.weaponSkill, createUnitRequest.characteristics.weaponSkill)
        XCTAssertEqual(addedUnitCharacteristics?.balisticSkill, createUnitRequest.characteristics.balisticSkill)
        XCTAssertEqual(addedUnitCharacteristics?.strength, createUnitRequest.characteristics.strength)
        XCTAssertEqual(addedUnitCharacteristics?.toughness, createUnitRequest.characteristics.toughness)
        XCTAssertEqual(addedUnitCharacteristics?.wounds, createUnitRequest.characteristics.wounds)
        XCTAssertEqual(addedUnitCharacteristics?.attacks, createUnitRequest.characteristics.attacks)
        XCTAssertEqual(addedUnitCharacteristics?.leadership, createUnitRequest.characteristics.leadership)
        XCTAssertEqual(addedUnitCharacteristics?.save, createUnitRequest.characteristics.save)
    }

}
