@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class GameControllerTests: BaseTests {

    func testCreateGame() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: Game.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)

        let userId = try Customer.query(on: conn).filter(\.email == user.email).first().wait()?.id
        let gameUser = try game.users.query(on: conn).filter(\.id == userId).first().wait()
        XCTAssertEqual(gameUser?.id, userId)
        XCTAssertEqual(gameUser?.email, user.email)
    }
}
