@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class RoasterControllerTests: BaseTests {

    func testCreateRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try GameTestsUtils.createGame(user: user, app: app)
        let (request, response) = try RoasterTestsUtils.createRoaster(user: user, gameId: game.id, app: app)

        let roaster = try Roaster.find(response.id, on: conn).unwrap(or: RoasterHammerError.roasterIsMissing.error()).wait()
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
        let _ = try RoasterTestsUtils.createRoaster(user: user, gameId: game.id, app: app)

        let roasters = try app.getResponse(to: "games/\(game.id)/roasters",
            decodeTo: [RoasterResponse].self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let roaster = roasters[0]

        XCTAssertEqual(roasters.count, 1)
        XCTAssertEqual(roaster.id, roaster.id)
        XCTAssertEqual(roaster.name, roaster.name)
        XCTAssertEqual(roaster.totalPoints, 0)
    }

}
