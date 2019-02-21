@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class FactionControllerTests: BaseTests {

    func testCreateFaction() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (createFactionRequest, faction) = try FactionTestsUtils.createFaction(armyId: army.requireID(), app: app)
        let rules = try faction.rules.query(on: conn).all().wait()
        XCTAssertEqual(faction.name, createFactionRequest.name)
        XCTAssertEqual(rules.count, 1)
        XCTAssertEqual(rules[0].name, createFactionRequest.rules[0].name)
        XCTAssertEqual(rules[0].description, createFactionRequest.rules[0].description)
        XCTAssertNotNil(army)
        XCTAssertNotNil(army.id)
        XCTAssertEqual(army.name, "Chaos Space Marines")
    }

    func testGetAllFactions() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (createFactionRequest, _) = try FactionTestsUtils.createFaction(armyId: army.requireID(), app: app)
        let allFactions = try app.getResponse(to: "factions", decodeTo: [Faction].self)
        XCTAssertEqual(allFactions.count, 1)
        XCTAssertEqual(allFactions[0].name, createFactionRequest.name)
    }

    func testEditFaction() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, faction) = try FactionTestsUtils.createFaction(armyId: army.requireID(), app: app)
        let (_, newArmy) = try ArmyTestsUtils.createArmy(app: app)
        let newName = "New Faction Name"
        let newRules = [AddRuleRequest(name: "rule", description: "desc")]
        let editRequest = try EditFactionRequest(name: newName,
                                                 rules: newRules,
                                                 armyId: newArmy.requireID())
        let editedFaction = try app.getResponse(to: "factions/\(faction.requireID())",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: editRequest,
            decodeTo: FactionResponse.self)
        XCTAssertEqual(editedFaction.name, newName)
        XCTAssertEqual(editedFaction.rules.count, newRules.count)
        for editedFactionRule in editedFaction.rules {
            for newRule in newRules {
                XCTAssertEqual(editedFactionRule.name, newRule.name)
                XCTAssertEqual(editedFactionRule.description, newRule.description)
            }
        }

        let newArmyFactions = try newArmy.factions.query(on: conn).all().wait().filter { $0.id == faction.id! }
        XCTAssertEqual(newArmyFactions.count, 1)
    }

    func testDeleteFaction() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, faction) = try FactionTestsUtils.createFaction(armyId: army.requireID(), app: app)
        _ = try app.sendRequest(to: "factions/\(faction.requireID())", method: .DELETE)
        let allFactions = try app.getResponse(to: "factions", decodeTo: [Faction].self)
        XCTAssertEqual(allFactions.count, 0)
    }

}
