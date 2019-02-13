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
        XCTAssertEqual(editedArmy.rules[0].name, newRules[0].name)
        XCTAssertEqual(editedArmy.rules[0].description, newRules[0].description)
    }

}
