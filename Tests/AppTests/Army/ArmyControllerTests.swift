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

}
