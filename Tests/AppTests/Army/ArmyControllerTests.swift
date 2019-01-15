@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class ArmyControllerTests: BaseTests {

    func testCreateArmy() throws {
        let request = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: request,
                                       decodeTo: Army.self)
        XCTAssertNotNil(army.id)
        XCTAssertEqual(army.name, request.name)
    }

    func testGetAllArmies() throws {
        let request = CreateArmyRequest(name: "Chaos Space Marines")
        try app.sendRequest(to: "armies", method: .POST, headers: ["Content-Type": "application/json"], data: request)
        let armies = try app.getResponse(to: "armies", decodeTo: [Army].self)
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies[0].name, request.name)
    }

}
