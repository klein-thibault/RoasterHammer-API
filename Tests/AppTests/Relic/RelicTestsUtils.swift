@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class RelicTestsUtils {
    static func createRelicNoWeaponNoKeywords(app: Application) throws -> (request: AddRelicRequest, response: ArmyResponse) {
        let (_, army) = try ArmyTestsUtils.createArmy(app: app)
        let request = AddRelicRequest(name: "Relic Name",
                                      description: "Relic Desc",
                                      weaponId: nil,
                                      keywordIds: [])
        let relic = try app.getResponse(to: "armies/\(army.requireID())/relics",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: request,
            decodeTo: ArmyResponse.self)

        return (request, relic)
    }
}
