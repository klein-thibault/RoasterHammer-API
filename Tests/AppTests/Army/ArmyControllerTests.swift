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
                                       decodeTo: ArmyResponse.self)
        XCTAssertNotNil(army.id)
        XCTAssertEqual(army.name, request.name)
    }

    func testGetAllArmies() throws {
        let request = CreateArmyRequest(name: "Chaos Space Marines")
        try app.sendRequest(to: "armies", method: .POST, headers: ["Content-Type": "application/json"], data: request)
        let armies = try app.getResponse(to: "armies", decodeTo: [ArmyResponse].self)
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies[0].name, request.name)
    }

    func testAddArmyToRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        let createRoasterRequest = CreateRoasterRequest(name: "My Roaster")
        let roaster = try app.getResponse(to: "games/\(game.id)/roasters",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: createRoasterRequest,
            decodeTo: RoasterResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        let createArmyRequest = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createArmyRequest,
                                       decodeTo: ArmyResponse.self)

        let addArmyRequest = AddArmyToRoasterRequest(armyId: army.id)
        let finalRoaster = try app.getResponse(to: "roasters/\(roaster.id)/armies",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addArmyRequest,
            decodeTo: RoasterResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let finalRoasterArmies = finalRoaster.armies

        XCTAssertEqual(finalRoasterArmies.count, 1)
        XCTAssertEqual(finalRoasterArmies[0].id, army.id)
        XCTAssertEqual(finalRoasterArmies[0].name, army.name)
    }

}
