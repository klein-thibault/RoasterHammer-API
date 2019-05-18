@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class WarlordTraitTestsUtils {
    static func createWarlordTrait(app: Application) throws -> (request: AddWarlordTraitRequest, response: WarlordTraitResponse) {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let request = AddWarlordTraitRequest(name: "Warlord Trait Name",
                                             description: "Warlord Trait Description")

        let warlordTrait = try app.getResponse(to: "armies/\(army.requireID())/warlord-traits",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: request,
            decodeTo: WarlordTraitResponse.self)

        return (request, warlordTrait)
    }
}
