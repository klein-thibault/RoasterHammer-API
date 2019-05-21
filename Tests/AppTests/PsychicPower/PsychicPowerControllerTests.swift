@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class PsychicPowerControllerTests: BaseTests {

    func testCreatePsychicPower() throws {
        let (request, army) = try PsychicPowerTestsUtils.createPsychicPower(app: app)
        XCTAssertNotNil(army.psychicPowers[0].id)
        XCTAssertEqual(request.name, army.psychicPowers[0].name)
        XCTAssertEqual(request.description, army.psychicPowers[0].description)
    }

    func testDeletePsychicPower() throws {
        let (_, army) = try PsychicPowerTestsUtils.createPsychicPower(app: app)
        XCTAssertTrue(army.psychicPowers.count == 1)

        _ = try app.sendRequest(to: "/psychic-powers/\(army.psychicPowers[0].id)", method: .DELETE)

        let armyWithoutRelics = try app.getResponse(to: "armies/\(army.id)", decodeTo: ArmyResponse.self)
        XCTAssertTrue(armyWithoutRelics.psychicPowers.count == 0)
    }

}
