@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class UnitControllerTests: BaseTests {

    func testCreateUnit() throws {
        let (createUnitRequest, unit) = try UnitTestsUtils.createUnit(app: app)
        let unitCharacteristics = unit.characteristics

        XCTAssertNotNil(unit.id)
        XCTAssertEqual(unit.name, createUnitRequest.name)
        XCTAssertEqual(unit.cost, createUnitRequest.cost)
        XCTAssertEqual(unit.isUnique, createUnitRequest.isUnique)
        XCTAssertEqual(unit.unitType, "HQ")
        XCTAssertEqual(unitCharacteristics.movement, createUnitRequest.characteristics.movement)
        XCTAssertEqual(unitCharacteristics.weaponSkill, createUnitRequest.characteristics.weaponSkill)
        XCTAssertEqual(unitCharacteristics.balisticSkill, createUnitRequest.characteristics.balisticSkill)
        XCTAssertEqual(unitCharacteristics.strength, createUnitRequest.characteristics.strength)
        XCTAssertEqual(unitCharacteristics.toughness, createUnitRequest.characteristics.toughness)
        XCTAssertEqual(unitCharacteristics.wounds, createUnitRequest.characteristics.wounds)
        XCTAssertEqual(unitCharacteristics.attacks, createUnitRequest.characteristics.attacks)
        XCTAssertEqual(unitCharacteristics.leadership, createUnitRequest.characteristics.leadership)
        XCTAssertEqual(unitCharacteristics.save, createUnitRequest.characteristics.save)
        XCTAssertEqual(unit.keywords.count, createUnitRequest.keywords.count)
        XCTAssertEqual(unit.keywords[0], createUnitRequest.keywords[0].name)
        XCTAssertEqual(unit.rules.count, 1)
        XCTAssertEqual(unit.rules[0].name, createUnitRequest.rules[0].name)
        XCTAssertEqual(unit.rules[0].description, createUnitRequest.rules[0].description)
    }

    func testGettingAllUnits() throws {
        let (_, unit) = try UnitTestsUtils.createUnit(app: app)
        let units = try app.getResponse(to: "units", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(units[0].id, unit.id)
    }

    func testAddUnitToDetachment() throws {
        let user = try app.createAndLogUser()

        let (_, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)

        let createDetachmentRequest = CreateDetachmentRequest(name: "Patrol", commandPoints: 0, armyId: army.id!)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: createDetachmentRequest,
                                             decodeTo: Detachment.self)
        let unitRoles = try detachment.roles.query(on: conn).all().wait()

        let (createUnitRequest, unit) = try UnitTestsUtils.createUnit(app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id!)/roles/\(unitRoles[0].id!)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let updatedDetachmentRole = updatedDetachment.roles
        let addedUnit = updatedDetachmentRole[0].units
        let addedUnitCharacteristics = addedUnit[0].unit.characteristics
        XCTAssertEqual(addedUnit[0].unit.name, unit.name)
        XCTAssertEqual(addedUnit[0].unit.cost, unit.cost)
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
