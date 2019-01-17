@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class UnitRoleControllerTests: BaseTests {

    func testCreateUnitRole() throws {
        let request = CreateUnitRoleRequest(name: "Troops")
        let unitRole = try app.getResponse(to: "unitRoles",
                                           method: .POST,
                                           headers: ["Content-Type": "application/json"],
                                           data: request,
                                           decodeTo: UnitRole.self)
        XCTAssertNotNil(unitRole.id)
        XCTAssertEqual(unitRole.name, request.name)
    }

}
