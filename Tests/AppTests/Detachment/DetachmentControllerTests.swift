@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class DetachmentControllerTests: BaseTests {

    func testCreateDetachment() throws {
        let createArmyRequest = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createArmyRequest,
                                       decodeTo: Army.self)

        let request = CreateDetachmentRequest(name: "Patrol", commandPoints: 0, armyId: army.id!)
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
        let createArmyRequest = CreateArmyRequest(name: "Chaos Space Marines")
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createArmyRequest,
                                       decodeTo: Army.self)

        let request = CreateDetachmentRequest(name: "Patrol", commandPoints: 0, armyId: army.id!)
        try app.sendRequest(to: "detachments",
                            method: .POST,
                            headers: ["Content-Type": "application/json"],
                            data: request)
        let detachemnts = try app.getResponse(to: "detachments", decodeTo: [Detachment].self)
        XCTAssertEqual(detachemnts.count, 1)
        XCTAssertEqual(detachemnts[0].name, request.name)
        XCTAssertEqual(detachemnts[0].commandPoints, request.commandPoints)
    }

    func testAddDetachmentToRoaster() throws {
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
                                       decodeTo: Army.self)

        let createDetachmentRequest = CreateDetachmentRequest(name: "Patrol", commandPoints: 0, armyId: army.id!)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: createDetachmentRequest,
                                             decodeTo: Detachment.self)

        let addDetachmentRequest = AddDetachmentToRoasterRequest(detachmentId: detachment.id!)
        try app.sendRequest(to: "roasters/\(roaster.id)/detachments",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addDetachmentRequest,
            loggedInRequest: true,
            loggedInCustomer: user)

        let updatedRoaster = try app.getResponse(to: "roasters/\(roaster.id)", decodeTo: RoasterResponse.self)
        XCTAssertEqual(updatedRoaster.detachments.count, 1)
        XCTAssertEqual(updatedRoaster.detachments[0].id, detachment.id!)
        XCTAssertEqual(updatedRoaster.detachments[0].name, detachment.name)
        XCTAssertEqual(updatedRoaster.detachments[0].commandPoints, detachment.commandPoints)
        XCTAssertEqual(updatedRoaster.detachments[0].army.id, army.id!)
        XCTAssertEqual(updatedRoaster.detachments[0].army.name, army.name)
    }

}
