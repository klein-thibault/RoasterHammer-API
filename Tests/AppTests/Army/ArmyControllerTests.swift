@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class ArmyControllerTests: BaseTests {

    func testCreateArmy() throws {
        let request = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: request,
                                       decodeTo: Army.self)
        XCTAssertNotNil(army.id)
        XCTAssertEqual(army.name, request.name)
    }

    func testGetAllArmies() throws {
        let request = CreateArmyRequest(name: "Chaos Space Marines")
        try app.sendRequest(to: "armies", method: .POST, headers: ["Content-Type": "application/json"], data: request)
        let armies = try app.getResponse(to: "armies", decodeTo: [Army].self)
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies[0].name, request.name)
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
        XCTAssertEqual(finalRoasterArmies[0].id!, army.id!)
        XCTAssertEqual(finalRoasterArmies[0].name, army.name)
    }

}
