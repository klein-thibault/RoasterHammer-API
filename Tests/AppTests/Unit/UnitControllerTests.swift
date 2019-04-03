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

    func testSelectWeaponForSelectedModel() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let model = unit.models[0]

        let addWeaponToUnitRequest = AddWeaponToModelRequest(minQuantity: 1, maxQuantity: 1)
        try app.sendRequest(to: "units/\(unit.id)/models/\(model.id)/weapons/\(weapon.id!)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addWeaponToUnitRequest)

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
        let modelWeapon = addedModels[0].model.weapons[0]

        let updatedDetachmentWithWeapon = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapons/\(modelWeapon.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].models[0].selectedWeapons[0].name, modelWeapon.name)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].unit.cost, unit.cost)
        XCTAssertEqual(updatedDetachmentWithWeapon.roles[0].units[0].models[0].cost, unit.cost + weapon.cost)
    }

    func testSelectWeaponForSelectedModel_whenModelWeaponsAreMaxedOut() throws {
        let user = try app.createAndLogUser()
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let unitRoles = detachment.roles
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, unit) = try UnitTestsUtils.createHQUniqueUnit(armyId: army.requireID(), app: app)
        let (_, weapon) = try WeaponTestsUtils.createWeapon(app: app)
        let model = unit.models[0]

        let addWeaponToUnitRequest = AddWeaponToModelRequest(minQuantity: 1, maxQuantity: 1)
        try app.sendRequest(to: "units/\(unit.id)/models/\(model.id)/weapons/\(weapon.id!)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addWeaponToUnitRequest)

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
        let modelWeapon = addedModels[0].model.weapons[0]

        _ = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapons/\(modelWeapon.id)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            decodeTo: DetachmentResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        do {
            _ = try app.getResponse(to: "detachments/\(detachment.id)/models/\(addedModels[0].id)/weapons/\(modelWeapon.id)",
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

}
