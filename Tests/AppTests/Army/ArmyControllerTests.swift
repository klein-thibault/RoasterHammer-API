@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class ArmyControllerTests: BaseTests {

    func testCreateArmy() throws {
        let (request, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)
        XCTAssertNotNil(army.id)
        XCTAssertEqual(army.name, request.name)
    }

    func testGetAllArmies() throws {
        let (request, _) = try ArmyTestsUtils.createArmyWithFaction(app: app)
        let armies = try app.getResponse(to: "armies", decodeTo: [ArmyResponse].self)
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies[0].name, request.name)
        XCTAssertEqual(armies[0].rules[0].name, request.rules[0].name)
        XCTAssertEqual(armies[0].rules[0].description, request.rules[0].description)
    }

    func testEditArmy() throws {
        let (_, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)
        let newName = "New Army Name"
        let newRules = [AddRuleRequest(name: "rule", description: "desc")]
        let editRequest = EditArmyRequest(name: newName, rules: newRules)
        let editedArmy = try app.getResponse(to: "armies/\(army.requireID())",
                                             method: .PATCH,
                                             headers: ["Content-Type": "application/json"],
                                             data: editRequest,
                                             decodeTo: ArmyResponse.self)
        XCTAssertEqual(editedArmy.name, newName)
        XCTAssertEqual(editedArmy.rules.count, newRules.count)
        for editedArmyRule in editedArmy.rules {
            for newRule in newRules {
                XCTAssertEqual(editedArmyRule.name, newRule.name)
                XCTAssertEqual(editedArmyRule.description, newRule.description)
            }
        }
    }

    func testEditArmy_nameOnly() throws {
        let (_, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)
        let currentArmyRules = try army.rules.query(on: conn).all().wait()
        let newName = "New Army Name"
        let editRequest = EditArmyRequest(name: newName, rules: nil)
        let editedArmy = try app.getResponse(to: "armies/\(army.requireID())",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: editRequest,
            decodeTo: ArmyResponse.self)
        XCTAssertEqual(editedArmy.name, newName)
        XCTAssertEqual(editedArmy.rules.count, currentArmyRules.count)
        for editedArmyRule in editedArmy.rules {
            for currentArmyRule in currentArmyRules {
                XCTAssertEqual(editedArmyRule.name, currentArmyRule.name)
                XCTAssertEqual(editedArmyRule.description, currentArmyRule.description)
            }
        }
    }

    func testEditArmy_rulesOnly() throws {
        let (_, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)
        let newRules = [AddRuleRequest(name: "rule", description: "desc")]
        let editRequest = EditArmyRequest(name: nil, rules: newRules)
        let editedArmy = try app.getResponse(to: "armies/\(army.requireID())",
            method: .PATCH,
            headers: ["Content-Type": "application/json"],
            data: editRequest,
            decodeTo: ArmyResponse.self)
        XCTAssertEqual(editedArmy.name, army.name)
        XCTAssertEqual(editedArmy.rules.count, newRules.count)
        for editedArmyRule in editedArmy.rules {
            for newRule in newRules {
                XCTAssertEqual(editedArmyRule.name, newRule.name)
                XCTAssertEqual(editedArmyRule.description, newRule.description)
            }
        }
    }

}
