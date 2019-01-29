@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class UnitControllerTests: BaseTests {

    func testCreateUnit() throws {
        let (createUnitRequest, unit) = try UnitTestsUtils.createUnit(app: app)
        let createModelRequest = createUnitRequest.models[0]
        let modelCharacteristics = unit.models[0].characteristics

        XCTAssertNotNil(unit.id)
        XCTAssertEqual(unit.name, createUnitRequest.name)
        XCTAssertEqual(unit.cost, createUnitRequest.cost)
        XCTAssertEqual(unit.minQuantity, createUnitRequest.minQuantity)
        XCTAssertEqual(unit.maxQuantity, createUnitRequest.maxQuantity)
        XCTAssertEqual(unit.models[0].weaponQuantity, createUnitRequest.models[0].weaponQuantity)
        XCTAssertEqual(unit.isUnique, createUnitRequest.isUnique)
        XCTAssertEqual(unit.unitType, "HQ")
        XCTAssertEqual(modelCharacteristics.movement, createModelRequest.characteristics.movement)
        XCTAssertEqual(modelCharacteristics.weaponSkill, createModelRequest.characteristics.weaponSkill)
        XCTAssertEqual(modelCharacteristics.balisticSkill, createModelRequest.characteristics.balisticSkill)
        XCTAssertEqual(modelCharacteristics.strength, createModelRequest.characteristics.strength)
        XCTAssertEqual(modelCharacteristics.toughness, createModelRequest.characteristics.toughness)
        XCTAssertEqual(modelCharacteristics.wounds, createModelRequest.characteristics.wounds)
        XCTAssertEqual(modelCharacteristics.attacks, createModelRequest.characteristics.attacks)
        XCTAssertEqual(modelCharacteristics.leadership, createModelRequest.characteristics.leadership)
        XCTAssertEqual(modelCharacteristics.save, createModelRequest.characteristics.save)
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
        let createModelRequest = createUnitRequest.models[0]

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
        let addedModelCharacteristics = addedUnit[0].unit.models[0].characteristics
        XCTAssertEqual(addedUnit[0].unit.name, unit.name)
        XCTAssertEqual(addedUnit[0].unit.cost, unit.cost)
        XCTAssertEqual(addedModelCharacteristics.movement, createModelRequest.characteristics.movement)
        XCTAssertEqual(addedModelCharacteristics.weaponSkill, createModelRequest.characteristics.weaponSkill)
        XCTAssertEqual(addedModelCharacteristics.balisticSkill, createModelRequest.characteristics.balisticSkill)
        XCTAssertEqual(addedModelCharacteristics.strength, createModelRequest.characteristics.strength)
        XCTAssertEqual(addedModelCharacteristics.toughness, createModelRequest.characteristics.toughness)
        XCTAssertEqual(addedModelCharacteristics.wounds, createModelRequest.characteristics.wounds)
        XCTAssertEqual(addedModelCharacteristics.attacks, createModelRequest.characteristics.attacks)
        XCTAssertEqual(addedModelCharacteristics.leadership, createModelRequest.characteristics.leadership)
        XCTAssertEqual(addedModelCharacteristics.save, createModelRequest.characteristics.save)
    }

    func testAddUnitToDetachment_whenDetachmentHasTooManyUnits() throws {
        // TODO
    }

}
