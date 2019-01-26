@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class RoasterControllerTests: BaseTests {

    func testCreateRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try GameTestsUtils.createGame(user: user, app: app)
        let (request, response) = try RoasterTestsUtils.createRoaster(user: user, gameId: game.id, app: app)

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
        let game = try GameTestsUtils.createGame(user: user, app: app)
        let (_, roaster) = try RoasterTestsUtils.createRoaster(user: user, gameId: game.id, app: app)

        let response = try app.getResponse(to: "games/\(game.id)/roasters",
            decodeTo: [RoasterResponse].self,
            loggedInRequest: true,
            loggedInCustomer: user)

        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response[0].id, roaster.id)
        XCTAssertEqual(response[0].name, roaster.name)
    }

}
