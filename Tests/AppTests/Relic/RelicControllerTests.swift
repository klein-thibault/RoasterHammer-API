@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class RelicControllerTests: BaseTests {

    func testCreateRelic() throws {
        let (request, army) = try RelicTestsUtils.createRelicNoWeaponNoKeywords(app: app)
        XCTAssertNotNil(army.relics[0].id)
        XCTAssertEqual(request.name, army.relics[0].name)
        XCTAssertEqual(request.description, army.relics[0].description)
    }

    func testDeleteRelic() throws {
        let (_, army) = try RelicTestsUtils.createRelicNoWeaponNoKeywords(app: app)
        XCTAssertTrue(army.relics.count == 1)

        _ = try app.sendRequest(to: "relics/\(army.relics[0].id)", method: .DELETE)

        let armyWithoutRelics = try app.getResponse(to: "armies/\(army.id)", decodeTo: ArmyResponse.self)
        XCTAssertTrue(armyWithoutRelics.relics.count == 0)
    }

}
