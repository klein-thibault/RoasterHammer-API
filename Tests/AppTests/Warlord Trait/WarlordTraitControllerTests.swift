@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class WarlordTraitControllerTests: BaseTests {

    func testCreateWarlordTrait() throws {
        let (request, warlordTrait) = try WarlordTraitTestsUtils.createWarlordTrait(app: app)
        XCTAssertEqual(request.name, warlordTrait.name)
        XCTAssertEqual(request.description, warlordTrait.description)
    }

    func testDeleteWarlordTrait() throws {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let request = AddWarlordTraitRequest(name: "Warlord Trait Name",
                                             description: "Warlord Trait Description")

        let warlordTrait = try app.getResponse(to: "armies/\(army.requireID())/warlord-traits",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: request,
            decodeTo: WarlordTraitResponse.self)

        let armyWithWarlordTrait = try app.getResponse(to: "armies/\(army.requireID())", decodeTo: ArmyResponse.self)
        XCTAssertTrue(armyWithWarlordTrait.warlordTraits.count > 0)

        _ = try app.sendRequest(to: "warlord-traits/\(warlordTrait.id)", method: .DELETE)

        let armyWithNoWarlordTraits = try app.getResponse(to: "armies/\(army.requireID())", decodeTo: ArmyResponse.self)
        XCTAssertTrue(armyWithNoWarlordTraits.warlordTraits.count == 0)
    }

}
