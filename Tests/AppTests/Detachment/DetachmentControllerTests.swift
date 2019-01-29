@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class DetachmentControllerTests: BaseTests {

    func testCreateDetachment() throws {
        let (request, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        XCTAssertEqual(detachment.name, request.name)
        XCTAssertEqual(detachment.commandPoints, request.commandPoints)

        let unitRoles = try detachment.roles.query(on: conn).all().wait()
        XCTAssertEqual(unitRoles.count, 6)
        XCTAssertEqual(unitRoles[0].name, Constants.RoleName.hq)
        XCTAssertEqual(unitRoles[1].name, Constants.RoleName.troop)
        XCTAssertEqual(unitRoles[2].name, Constants.RoleName.elite)
        XCTAssertEqual(unitRoles[3].name, Constants.RoleName.fastAttack)
        XCTAssertEqual(unitRoles[4].name, Constants.RoleName.heavySupport)
        XCTAssertEqual(unitRoles[5].name, Constants.RoleName.flyer)
    }

    func testGetAllDetachments() throws {
        let (request, _) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)
        let detachments = try app.getResponse(to: "detachments", decodeTo: [Detachment].self)
        XCTAssertEqual(detachments.count, 1)
        XCTAssertEqual(detachments[0].name, request.name)
        XCTAssertEqual(detachments[0].commandPoints, request.commandPoints)
    }

    func testAddDetachmentToRoaster() throws {
        let user = try app.createAndLogUser()
        let game = try GameTestsUtils.createGame(user: user, app: app)
        let (_, roaster) = try RoasterTestsUtils.createRoaster(user: user, gameId: game.id, app: app)
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)

        let addDetachmentRequest = AddDetachmentToRoasterRequest(detachmentId: detachment.id!)
        try app.sendRequest(to: "roasters/\(roaster.id)/detachments",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addDetachmentRequest,
            loggedInRequest: true,
            loggedInCustomer: user)

        let army = try detachment.army.get(on: conn).wait()
        let factions = try army.factions.query(on: conn).all().wait()
        let updatedRoaster = try app.getResponse(to: "roasters/\(roaster.id)", decodeTo: RoasterResponse.self)
        XCTAssertEqual(updatedRoaster.detachments.count, 1)
        XCTAssertEqual(updatedRoaster.detachments[0].id, detachment.id!)
        XCTAssertEqual(updatedRoaster.detachments[0].name, detachment.name)
        XCTAssertEqual(updatedRoaster.detachments[0].commandPoints, detachment.commandPoints)
        XCTAssertEqual(updatedRoaster.detachments[0].army.id, army.id!)
        XCTAssertEqual(updatedRoaster.detachments[0].army.name, army.name)
        XCTAssertEqual(updatedRoaster.detachments[0].army.factions.count, factions.count)
        XCTAssertEqual(updatedRoaster.detachments[0].army.factions[0].name, factions[0].name)
    }

    func testSelectDetachmentFaction() throws {
        let user = try app.createAndLogUser()
        let game = try GameTestsUtils.createGame(user: user, app: app)
        let (_, roaster) = try RoasterTestsUtils.createRoaster(user: user, gameId: game.id, app: app)
        let (_, detachment) = try DetachmentTestsUtils.createPatrolDetachmentWithArmy(app: app)

        let addDetachmentRequest = AddDetachmentToRoasterRequest(detachmentId: detachment.id!)
        try app.sendRequest(to: "roasters/\(roaster.id)/detachments",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: addDetachmentRequest,
            loggedInRequest: true,
            loggedInCustomer: user)

        let army = try detachment.army.get(on: conn).wait()
        let faction = try army.factions.query(on: conn).first().unwrap(or: RoasterHammerError.factionIsMissing.error()).wait()

        let updatedRoaster = try app.getResponse(to: "roasters/\(roaster.id)/detachments/\(detachment.id!)/factions/\(faction.id!)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: nil,
            decodeTo: RoasterResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)
        XCTAssertNotNil(updatedRoaster.detachments[0].selectedFaction)
    }

}
