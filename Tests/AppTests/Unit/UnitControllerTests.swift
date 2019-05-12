@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class UnitControllerTests: BaseTests {

    func testCreateUnit() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (createUnitRequest, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let createModelRequest = createUnitRequest.models[0]
        let modelCharacteristics = unit.models[0].characteristics

        XCTAssertNotNil(unit.id)
        XCTAssertEqual(unit.name, createUnitRequest.name)
        XCTAssertEqual(unit.minQuantity, createUnitRequest.minQuantity)
        XCTAssertEqual(unit.maxQuantity, createUnitRequest.maxQuantity)
        XCTAssertEqual(unit.models[0].weaponQuantity, createUnitRequest.models[0].weaponQuantity)
        XCTAssertEqual(unit.isUnique, createUnitRequest.isUnique)
        XCTAssertEqual(unit.unitType, "HQ")
        XCTAssertEqual(unit.cost, 120)
        XCTAssertEqual(unit.models[0].cost, createUnitRequest.models[0].cost)
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
        XCTAssertEqual(unit.keywords[0], createUnitRequest.keywords[0])
        XCTAssertEqual(unit.rules.count, 1)
        XCTAssertEqual(unit.rules[0].name, createUnitRequest.rules[0].name)
        XCTAssertEqual(unit.rules[0].description, createUnitRequest.rules[0].description)
    }

    func testGettingAllUnits() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let units = try app.getResponse(to: "units", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(units[0].id, unit.id)
    }

    func testGettingAllUnits_withArmyIdFilter_whenArmyExists() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let armyId = try army.requireID()
        let units = try app.getResponse(to: "units?armyId=\(String(armyId))", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(units[0].id, unit.id)
        XCTAssertEqual(units[0].army.id, army.id!)
    }

    func testGettingAllUnits_withArmyIdFilter_whenArmyDoesntExist() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        _ = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let units = try app.getResponse(to: "units?armyId=1234", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 0)
    }

    func testGettingAllUnits_withUnitTypeFilter_whenUnitTypeExists() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let armyId = try army.requireID()
        let units = try app.getResponse(to: "units?armyId=\(String(armyId))&unitType=HQ", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(units[0].id, unit.id)
        XCTAssertEqual(units[0].army.id, army.id!)
        XCTAssertEqual(units[0].unitType, "HQ")
    }

    func testGettingAllUnits_withUnitTypeFilter_whenUnitTypeDoesntExists() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, _) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let armyId = try army.requireID()
        let units = try app.getResponse(to: "units?armyId=\(String(armyId))&unitType=Troop", decodeTo: [UnitResponse].self)
        XCTAssertEqual(units.count, 0)
    }

    func testEditUnit() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, army2) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let editedCharacteristics = CreateCharacteristicsRequest(movement: "New Movement",
                                                                 weaponSkill: "New Weapon Skill",
                                                                 balisticSkill: "New Balistic Skill",
                                                                 strength: "New Strength",
                                                                 toughness: "New Toughness",
                                                                 wounds: "New Wounds",
                                                                 attacks: "New Attack",
                                                                 leadership: "New Ld",
                                                                 save: "New Save")
        let editModelRequest = CreateModelRequest(name: "New Model Name",
                                                  cost: 999,
                                                  minQuantity: 9,
                                                  maxQuantity: 999,
                                                  weaponQuantity: 9,
                                                  characteristics: editedCharacteristics)
        let editedRuleRequest = AddRuleRequest(name: "New Rule Name", description: "New Rule Desc")
        let editUnitRequest = CreateUnitRequest(name: "New Name",
                                                isUnique: false,
                                                minQuantity: 9,
                                                maxQuantity: 999,
                                                unitTypeId: 3,
                                                armyId: army2.id!,
                                                models: [editModelRequest],
                                                keywords: ["New Keyword Name"],
                                                rules: [editedRuleRequest])
        let editedUnit = try app.getResponse(to: "units/\(unit.id)",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: editUnitRequest,
            decodeTo: UnitResponse.self)

        let modelCharacteristics = editedUnit.models[0].characteristics
        XCTAssertNotNil(editedUnit.id)
        XCTAssertEqual(editedUnit.name, editUnitRequest.name)
        XCTAssertEqual(editedUnit.minQuantity, editUnitRequest.minQuantity)
        XCTAssertEqual(editedUnit.maxQuantity, editUnitRequest.maxQuantity)
        XCTAssertEqual(editedUnit.models[0].weaponQuantity, editUnitRequest.models[0].weaponQuantity)
        XCTAssertEqual(editedUnit.isUnique, editUnitRequest.isUnique)
        XCTAssertEqual(editedUnit.unitType, "Elite")
        XCTAssertEqual(editedUnit.cost, 999)
        XCTAssertEqual(editedUnit.models[0].cost, editUnitRequest.models[0].cost)
        XCTAssertEqual(modelCharacteristics.movement, editModelRequest.characteristics.movement)
        XCTAssertEqual(modelCharacteristics.weaponSkill, editModelRequest.characteristics.weaponSkill)
        XCTAssertEqual(modelCharacteristics.balisticSkill, editModelRequest.characteristics.balisticSkill)
        XCTAssertEqual(modelCharacteristics.strength, editModelRequest.characteristics.strength)
        XCTAssertEqual(modelCharacteristics.toughness, editModelRequest.characteristics.toughness)
        XCTAssertEqual(modelCharacteristics.wounds, editModelRequest.characteristics.wounds)
        XCTAssertEqual(modelCharacteristics.attacks, editModelRequest.characteristics.attacks)
        XCTAssertEqual(modelCharacteristics.leadership, editModelRequest.characteristics.leadership)
        XCTAssertEqual(modelCharacteristics.save, editModelRequest.characteristics.save)
        XCTAssertEqual(editedUnit.keywords.count, editUnitRequest.keywords.count)
        XCTAssertEqual(editedUnit.keywords[0], editUnitRequest.keywords[0])
        XCTAssertEqual(editedUnit.rules.count, 1)
        XCTAssertEqual(editedUnit.rules[0].name, editUnitRequest.rules[0].name)
        XCTAssertEqual(editedUnit.rules[0].description, editUnitRequest.rules[0].description)
    }

    func testAssignRuleToUnit() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, rule) = try RuleTestsUtils.createRule(conn: conn)

        let unitRule = try UnitDatabaseQueries().assignRuleToUnit(unitId: unit.id, rule: rule, conn: conn).wait()

        XCTAssertEqual(unit.id, unitRule.unitId)
        XCTAssertEqual(rule.id, unitRule.ruleId)

        let editedUnit = try app.getResponse(to: "units/\(unit.id)", decodeTo: UnitResponse.self)
        XCTAssertTrue(editedUnit.rules.count == 2)
        XCTAssertEqual(editedUnit.rules[1].name, rule.name)
        XCTAssertEqual(editedUnit.rules[1].description, rule.description)
    }

    func testDeleteUnit() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        _ = try app.sendRequest(to: "units/\(unit.id)", method: .DELETE)

        do {
            _ = try app.getResponse(to: "units/\(unit.id)", decodeTo: UnitResponse.self)
            XCTFail("Should have received a missing army error")
        } catch {
            print(error)
            XCTAssertNotNil(error)
        }
    }

    func testAddUnitToDetachment() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (createUnitRequest, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let createModelRequest = createUnitRequest.models[0]

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
        let addedModelCharacteristics = addedUnit[0].unit.models[0].characteristics
        XCTAssertEqual(addedUnit[0].unit.name, unit.name)
        XCTAssertEqual(addedUnit[0].unit.cost, unit.cost)
        XCTAssertFalse(addedUnit[0].isWarlord)

        // Make sure that the expected amount of models have been added
        let expectedModelsCount = addedUnit[0].unit.models.reduce(0) { $0 + $1.minQuantity }
        XCTAssertEqual(addedUnit[0].models.count, expectedModelsCount)

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

    func testAddUnitToDetachment_whenUniqueUnitWasAddedOnce() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        do {
            _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
                method: .POST,
                headers: ["Content-Type": "application/json"],
                data: addUnitToDetachmentRequest,
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have received an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testAddUnitToDetachment_whenAddingToWrongRole() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        do {
            let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
            // Adding to the wrong unit role (Troop instead of HQ)
            _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[1].id)/units/\(unit.id)",
                method: .POST,
                headers: ["Content-Type": "application/json"],
                data: addUnitToDetachmentRequest,
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have received an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testAddUnitToDetachment_whenDetachmentHasTooManyUnits() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, uniqueUnit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, hqUnit1) = try UnitTestsUtils.createHQUnit(armyId: army.requireID(), app: app)
        let (_, hqUnit2) = try UnitTestsUtils.createHQUnit(armyId: army.requireID(), app: app)

        // Add unique HQ
        let addUniqueUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: uniqueUnit.maxQuantity)
        _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(uniqueUnit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUniqueUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        // Add HQ unit 1
        let addHQUnit1ToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: hqUnit1.maxQuantity)
        _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(hqUnit1.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addHQUnit1ToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        do {
            // Add HQ unit 2
            let addHQUnit2ToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: hqUnit2.maxQuantity)
            _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(hqUnit2.id)",
                method: .POST,
                headers: ["Content-Type": "application/json"],
                data: addHQUnit2ToDetachmentRequest,
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have received an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testRemoveUnitFromDetachment() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

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
        XCTAssertTrue(updatedDetachmentRole[0].units.count == 1)
        XCTAssertEqual(addedUnit[0].unit.name, unit.name)
        XCTAssertEqual(addedUnit[0].unit.cost, unit.cost)

        let detachmentAfterRemovingModel = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .DELETE,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let updatedDetachmentRoleAfterRemovingModel = detachmentAfterRemovingModel.roles
        XCTAssertTrue(updatedDetachmentRoleAfterRemovingModel[0].units.count == 0)
    }

    func testSetUnitAsWarlord() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let futureWarlord = updatedDetachment.roles[0].units[0]
        XCTAssertFalse(futureWarlord.isWarlord)

        let detachmentWithWarlord = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)/warlord",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let warlord = detachmentWithWarlord.roles[0].units[0]
        XCTAssertTrue(warlord.isWarlord)
    }

    func testSetUnitAsWarlord_whenUnitIsNotAHQ() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createTroopUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[1].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let futureWarlord = updatedDetachment.roles[1].units[0]
        XCTAssertFalse(futureWarlord.isWarlord)

        do {
            _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[1].id)/units/\(unit.id)/warlord",
                method: .PATCH,
                headers: ["Content-Type": "application/json"],
                data: nil,
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have received an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testSetUnitAsWarlord_whenUnitIsAlreadyWarlord() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let futureWarlord = updatedDetachment.roles[0].units[0]
        XCTAssertFalse(futureWarlord.isWarlord)

        let detachmentWithWarlord = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)/warlord",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        XCTAssertTrue(detachmentWithWarlord.roles[0].units[0].isWarlord)

        let detachmentWithNoWarlord = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)/warlord",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        XCTAssertFalse(detachmentWithNoWarlord.roles[0].units[0].isWarlord)
    }

    func testSetUnitAsWarlord_whenAnotherUnitIsWarlord() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit1) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, unit2) = try UnitTestsUtils.createHQUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest1 = AddUnitToDetachmentRequest(unitQuantity: unit1.maxQuantity)
        _ = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit1.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest1,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let addUnitToDetachmentRequest2 = AddUnitToDetachmentRequest(unitQuantity: unit2.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit2.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest2,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        for unit in updatedDetachment.roles[0].units {
            XCTAssertFalse(unit.isWarlord)
        }

        let detachmentWithWarlord1 = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit1.id)/warlord",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        for unit in detachmentWithWarlord1.roles[0].units {
            if unit.id == unit1.id {
                XCTAssertTrue(unit.isWarlord)
            } else {
                XCTAssertFalse(unit.isWarlord)
            }
        }

        let detachmentWithWarlord2 = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit2.id)/warlord",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        for unit in detachmentWithWarlord2.roles[0].units {
            if unit.id == unit2.id {
                XCTAssertTrue(unit.isWarlord)
            } else {
                XCTAssertFalse(unit.isWarlord)
            }
        }
    }

    func testAddModelToUnit() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let troopRoleId = unitRoles.filter({ $0.name == "Troop" }).first!.id
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createTroopUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(troopRoleId)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let oldModels = updatedDetachment.roles[1].units[0].models
        let modelIdToAdd = updatedDetachment.roles[1].units[0].models[0].id
        let updatedDetachmentWithNewModel = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(modelIdToAdd)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let newModels = updatedDetachmentWithNewModel.roles[1].units[0].models
        XCTAssertTrue(newModels.count == oldModels.count + 1)
    }

    func testAddModelToUnit_whenUnitHasTooManyModels() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let modelIdToAdd = updatedDetachment.roles[0].units[0].models[0].id

        do {
            _ = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(modelIdToAdd)",
                method: .POST,
                headers: ["Content-Type": "application/json"],
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have received an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testRemoveModelFromUnit() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let troopRoleId = unitRoles.filter({ $0.name == "Troop" }).first!.id
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createTroopUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(troopRoleId)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let oldModels = updatedDetachment.roles[1].units[0].models
        let modelIdToUse = updatedDetachment.roles[1].units[0].models[0].id
        let updatedDetachmentWithNewModel = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(modelIdToUse)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let newModels = updatedDetachmentWithNewModel.roles[1].units[0].models
        XCTAssertTrue(newModels.count == oldModels.count + 1)

        let selectedModelIdToRemove = updatedDetachmentWithNewModel.roles[1].units[0].models[0].id
        let updatedDetachmentAfterRemovingNewModel = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(selectedModelIdToRemove)",
            method: .DELETE,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let newModelsAfterRemoval = updatedDetachmentAfterRemovingNewModel.roles[1].units[0].models
        XCTAssertTrue(newModelsAfterRemoval.count == oldModels.count)
    }

    func testRemoveModelFromUnit_whenUnitAlreadyHasTheMinimalAmountOfModels() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let troopRoleId = unitRoles.filter({ $0.name == "Troop" }).first!.id
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createTroopUnit(armyId: army.requireID(), app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        let updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(troopRoleId)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let oldModels = updatedDetachment.roles[1].units[0].models
        let modelIdToUse = updatedDetachment.roles[1].units[0].models[0].id
        let updatedDetachmentWithNewModel = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(modelIdToUse)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let newModels = updatedDetachmentWithNewModel.roles[1].units[0].models
        XCTAssertTrue(newModels.count == oldModels.count + 1)

        let firstSelectedModelIdToRemove = updatedDetachmentWithNewModel.roles[1].units[0].models[0].id
        let secondSelectedModelIdToRemove = updatedDetachmentWithNewModel.roles[1].units[0].models[1].id
        // Remove 1st model, putting back the number of models to the min quantity required in the unit
        _ = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(firstSelectedModelIdToRemove)",
            method: .DELETE,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        do {
            // Remove 2nd model, making the number of models under the min quantity required in the unit
            _ = try app.getResponse(to: "detachments/\(detachment.id)/units/\(unit.id)/models/\(secondSelectedModelIdToRemove)",
                method: .DELETE,
                headers: ["Content-Type": "application/json"],
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have received an error")
        } catch {
            XCTAssertNotNil(error)
        }

    }

    func testSelectWeaponForSelectedModel() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createPistolWeapon(app: app)
        let model = unit.models[0]

        let weaponBucket = try WeaponBucketTestUtils.assignWeaponToModel(weaponId: weapon.requireID(),
                                                                         modelId: model.id,
                                                                         app: app)

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
        let addedModels = addedUnit[0].models
        let modelWeapon = weaponBucket.weapons[0]

        let updatedDetachmentWithWeapon = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].models[0].selectedWeapons[0].name, modelWeapon.name)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].unit.cost, unit.cost)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].models[0].cost, unit.cost + weapon.cost)
    }

    func testSelectWeaponForSelectedModel_replacingExistingWeapon() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createPistolWeapon(app: app)
        let model = unit.models[0]

        let weaponBucket = try WeaponBucketTestUtils.assignWeaponToModel(weaponId: weapon.requireID(),
                                                                         modelId: model.id,
                                                                         app: app)

        let addUnitToDetachmentRequest = AddUnitToDetachmentRequest(unitQuantity: unit.maxQuantity)
        var updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/roles/\(unitRoles[0].id)/units/\(unit.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addUnitToDetachmentRequest,
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let updatedDetachmentRole = updatedDetachment.roles
        let addedUnit = updatedDetachmentRole[0].units
        let addedModels = addedUnit[0].models
        let modelWeapon = weaponBucket.weapons[0]

        _ = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        updatedDetachment = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        XCTAssertEqual(updatedDetachment.roles[0].units[0].models[0].selectedWeapons[0].name, modelWeapon.name)
        XCTAssertEqual(updatedDetachment.roles[0].units[0].unit.cost, unit.cost)
        XCTAssertEqual(updatedDetachment.roles[0].units[0].models[0].cost, unit.cost + weapon.cost)
    }

    func testSelectWeaponForSelectedModel_whenModelWeaponsAreMaxedOut() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(),
                                                              app: app,
                                                              weaponQuantity: 2)
        let (_, pistolWeapon) = try WeaponTestsUtils.createPistolWeapon(app: app)
        let (_, bolterWeapon) = try WeaponTestsUtils.createBolterWeapon(app: app)
        let (_, heavyBolterWeapon) = try WeaponTestsUtils.createHeavyWeapon(app: app)
        let model = unit.models[0]

        var weaponBucket = try WeaponBucketTestUtils.assignWeaponToModel(weaponId: pistolWeapon.requireID(),
                                                                         modelId: model.id,
                                                                         app: app,
                                                                         minWeaponQuantity: 2,
                                                                         maxWeaponQuantity: 2)

        // Add bolter to weapon bucket
        let _ = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/weapons/\(bolterWeapon.requireID())",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucket.self)
        // Add heavy bolter to weapon bucket
        let _ = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)/weapons/\(heavyBolterWeapon.requireID())",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: WeaponBucket.self)

        weaponBucket = try app.getResponse(to: "weapon-buckets/\(weaponBucket.id)", decodeTo: WeaponBucketResponse.self)

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
        let addedModels = addedUnit[0].models
        let modelWeapon1 = weaponBucket.weapons[0]
        let modelWeapon2 = weaponBucket.weapons[1]
        let modelWeapon3 = weaponBucket.weapons[2]

        _ = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon1.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        _ = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon2.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        do {
            _ = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon3.id)",
                method: .POST,
                headers: ["Content-Type": "application/json"],
                decodeTo: DetachmentResponse.self,
                loggedInRequest: true,
                loggedInCustomer: user)
            XCTFail("Should have returned an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testUnselectWeaponForSelectedModel() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createPistolWeapon(app: app)
        let model = unit.models[0]

        let weaponBucket = try WeaponBucketTestUtils.assignWeaponToModel(weaponId: weapon.requireID(),
                                                                         modelId: model.id,
                                                                         app: app)

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
        let addedModels = addedUnit[0].models
        let modelWeapon = weaponBucket.weapons[0]

        // Assign weapon to model
        let updatedDetachmentWithWeapon = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].models[0].selectedWeapons[0].name, modelWeapon.name)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].unit.cost, unit.cost)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].models[0].cost, unit.cost + weapon.cost)

        // Unassign weapon to model
        let updatedDetachmentWithoutWeapon = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapon-buckets/\(weaponBucket.id)/weapons/\(modelWeapon.id)",
            method: .DELETE,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        XCTAssertEqual(updatedDetachmentWithoutWeapon.roles[0].units[0].models[0].selectedWeapons.count, 0)
        XCTAssertEqual(updatedDetachmentWithoutWeapon.roles[0].units[0].unit.cost, unit.cost)
        XCTAssertEqual(updatedDetachmentWithoutWeapon.roles[0].units[0].models[0].cost, unit.cost)
    }

}
