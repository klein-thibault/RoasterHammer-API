@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class RoasterControllerTests: BaseTests {

    func testCreateRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: Game.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let request = CreateRoasterRequest(name: "My Roaster", gameId: game.id!)
        let roaster = try app.getResponse(to: "/roasters",
                                          method: .POST,
                                          headers: ["Content-Type": "application/json"],
                                          data: request,
                                          decodeTo: Roaster.self,
                                          loggedInRequest: true,
                                          loggedInCustomer: user)
        let roasterGame = try roaster.game.get(on: conn).wait()

        XCTAssertEqual(roaster.name, request.name)
        XCTAssertEqual(roaster.version, 1)
        XCTAssertEqual(roaster.gameId, game.id)
        XCTAssertEqual(roasterGame.id, game.id)
        XCTAssertEqual(roasterGame.name, game.name)
        XCTAssertEqual(roasterGame.version, game.version)
    }

    func testGetRoasters() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: Game.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let request = CreateRoasterRequest(name: "My Roaster", gameId: game.id!)
        let roaster = try app.getResponse(to: "/roasters",
                                          method: .POST,
                                          headers: ["Content-Type": "application/json"],
                                          data: request,
                                          decodeTo: Roaster.self,
                                          loggedInRequest: true,
                                          loggedInCustomer: user)

        let roasters = try app.getResponse(to: "/roasters",
                                              method: .GET,
                                              decodeTo: [Roaster].self,
                                              loggedInRequest: true,
                                              loggedInCustomer: user)

        XCTAssertEqual(roasters.count, 1)
        XCTAssertEqual(roasters[0].id, roaster.id)
        XCTAssertEqual(roasters[0].name, roaster.name)
        XCTAssertEqual(roasters[0].gameId, roaster.gameId)
    }

}
