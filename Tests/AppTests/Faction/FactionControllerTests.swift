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

    func testDeleteFaction() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let (_, faction) = try FactionTestsUtils.createFaction(armyId: army.requireID(), app: app)
        _ = try app.sendRequest(to: "factions/\(faction.requireID())", method: .DELETE)
        let allFactions = try app.getResponse(to: "factions", decodeTo: [Faction].self)
        XCTAssertEqual(allFactions.count, 0)
    }

}
