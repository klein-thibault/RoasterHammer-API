@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class RoasterControllerTests: BaseTests {

    func testCreateRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let request = CreateRoasterRequest(name: "My Roaster")
        let response = try app.getResponse(to: "games/\(game.id)/roasters",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: request,
            decodeTo: RoasterResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let roaster = try Roaster.find(response.id, on: conn).unwrap(or: RoasterHammerError.roasterIsMissing).wait()
        let roasterGame = try roaster.game.get(on: conn).wait()

        XCTAssertEqual(response.name, request.name)
        XCTAssertEqual(response.version, 1)
        XCTAssertEqual(roaster.gameId, game.id)
        XCTAssertEqual(roasterGame.id, game.id)
        XCTAssertEqual(roasterGame.name, game.name)
        XCTAssertEqual(roasterGame.version, game.version)
    }

    func testGetRoasters() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let request = CreateRoasterRequest(name: "My Roaster")
        let roaster = try app.getResponse(to: "games/\(game.id)/roasters",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: request,
            decodeTo: RoasterResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let response = try app.getResponse(to: "games/\(game.id)/roasters",
            decodeTo: [RoasterResponse].self,
            loggedInRequest: true,
            loggedInCustomer: user)

        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response[0].id, roaster.id)
        XCTAssertEqual(response[0].name, roaster.name)
    }

}
