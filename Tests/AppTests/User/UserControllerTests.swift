@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class UserControllerTests: BaseTests {

    func testCreateUser() throws {
        let user = try app.createAndLogUser()
        XCTAssertEqual(user.email, "test@test.com")
    }

}
