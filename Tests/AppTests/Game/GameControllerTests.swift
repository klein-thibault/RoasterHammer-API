@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class GameControllerTests: BaseTests {

    func testCreateGame() throws {
        let user = try app.createAndLogUser()
        let response = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)

        let userId = try Customer.query(on: conn).filter(\.email == user.email).first().wait()?.id
        let game = try Game.find(response.id, on: conn).unwrap(or: RoasterHammerError.gameIsMissing).wait()
        let gameUser = try game.users.query(on: conn).filter(\.id == userId).first().wait()
        XCTAssertEqual(gameUser?.id, userId)
        XCTAssertEqual(gameUser?.email, user.email)
    }

    func testGetGames() throws {
        let user = try app.createAndLogUser()
        let response = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let games = try app.getResponse(to: "games",
                                        method: .GET,
                                        decodeTo: [GameResponse].self,
                                        loggedInRequest: true,
                                        loggedInCustomer: user)
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].id, response.id)
        XCTAssertEqual(games[0].name, response.name)
        XCTAssertEqual(games[0].version, response.version)
    }

    func testGetGameById() throws {
        let user = try app.createAndLogUser()
        let response = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let gameById = try app.getResponse(to: "games/\(response.id)",
            decodeTo: Game.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        XCTAssertEqual(gameById.id!, response.id)
        XCTAssertEqual(gameById.name, response.name)
        XCTAssertEqual(gameById.version, response.version)
    }

}
