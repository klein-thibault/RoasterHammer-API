@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class DetachmentControllerTests: BaseTests {

    func testCreateDetachment() throws {
        let request = CreateDetachmentRequest(name: "Patrol", commandPoints: 0)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: request,
                                             decodeTo: Detachment.self)
        XCTAssertEqual(detachment.name, request.name)
        XCTAssertEqual(detachment.commandPoints, request.commandPoints)

        let unitRoles = try detachment.roles.query(on: conn).all().wait()
        XCTAssertEqual(unitRoles.count, 5)
        XCTAssertEqual(unitRoles[0].name, "HQ")
        XCTAssertEqual(unitRoles[1].name, "Troop")
        XCTAssertEqual(unitRoles[2].name, "Elite")
        XCTAssertEqual(unitRoles[3].name, "Fast Attack")
        XCTAssertEqual(unitRoles[4].name, "Heavy Support")
    }

    func testGetAllDetachments() throws {
        let request = CreateDetachmentRequest(name: "Patrol", commandPoints: 0)
        try app.sendRequest(to: "detachments",
                            method: .POST,
                            headers: ["Content-Type": "application/json"],
                            data: request)
        let detachemnts = try app.getResponse(to: "detachments", decodeTo: [Detachment].self)
        XCTAssertEqual(detachemnts.count, 1)
        XCTAssertEqual(detachemnts[0].name, request.name)
        XCTAssertEqual(detachemnts[0].commandPoints, request.commandPoints)
    }

    func testAddDetachmentToArmy() throws {
        let user = try app.createAndLogUser()
        let game = try app.getResponse(to: "games",
                                       method: .POST,
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
        try app.sendRequest(to: "games/\(game.id)/roasters/\(roaster.id)/armies",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addArmyRequest,
            loggedInRequest: true,
            loggedInCustomer: user)
        let createDetachmentRequest = CreateDetachmentRequest(name: "Patrol", commandPoints: 0)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: createDetachmentRequest,
                                             decodeTo: Detachment.self)

        let addDetachmentRequest = AddDetachmentToArmyRequest(detachmentId: detachment.id!)
        let finalArmy = try app.getResponse(to: "armies/\(army.id)/detachments",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addDetachmentRequest,
            decodeTo: ArmyResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        let finalArmyDetachments = finalArmy.detachments

        XCTAssertEqual(finalArmyDetachments.count, 1)
        XCTAssertEqual(finalArmyDetachments[0].id, detachment.id)
        XCTAssertEqual(finalArmyDetachments[0].name, detachment.name)
        XCTAssertEqual(finalArmyDetachments[0].commandPoints, detachment.commandPoints)
    }

}
