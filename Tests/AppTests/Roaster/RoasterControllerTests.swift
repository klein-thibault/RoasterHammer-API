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
        let request = CreateRoasterRequest(name: "My Roaster")
        let roaster = try app.getResponse(to: "games/\(game.id!)/roasters",
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
        let request = CreateRoasterRequest(name: "My Roaster")
        let roaster = try app.getResponse(to: "games/\(game.id!)/roasters",
                                          method: .POST,
                                          headers: ["Content-Type": "application/json"],
                                          data: request,
                                          decodeTo: Roaster.self,
                                          loggedInRequest: true,
                                          loggedInCustomer: user)

        let roasters = try app.getResponse(to: "games/\(game.id!)/roasters",
                                              method: .GET,
                                              decodeTo: [Roaster].self,
                                              loggedInRequest: true,
                                              loggedInCustomer: user)

        XCTAssertEqual(roasters.count, 1)
        XCTAssertEqual(roasters[0].id, roaster.id)
        XCTAssertEqual(roasters[0].name, roaster.name)
        XCTAssertEqual(roasters[0].gameId, roaster.gameId)
    }

    func testAddArmyToRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: Game.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let createRoasterRequest = CreateRoasterRequest(name: "My Roaster")
        let roaster = try app.getResponse(to: "games/\(game.id!)/roasters",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: createRoasterRequest,
            decodeTo: Roaster.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let createArmyRequest = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createArmyRequest,
                                       decodeTo: Army.self)

        let addArmyRequest = AddArmyToRoasterRequest(armyId: army.id!)
        let finalRoaster = try app.getResponse(to: "games/\(game.id!)/roasters/\(roaster.id!)/armies",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addArmyRequest,
            decodeTo: Roaster.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let finalRoasterArmies = try finalRoaster.armies.query(on: conn).all().wait()
        XCTAssertEqual(finalRoasterArmies.count, 1)
        XCTAssertEqual(finalRoasterArmies[0].name, army.name)
    }

}
