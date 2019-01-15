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

    func testGetGames() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: Game.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let games = try app.getResponse(to: "games",
                                        method: .GET,
                                        decodeTo: [Game].self,
                                        loggedInRequest: true,
                                        loggedInCustomer: user)
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].id, game.id)
        XCTAssertEqual(games[0].name, game.name)
        XCTAssertEqual(games[0].version, game.version)
    }

}
