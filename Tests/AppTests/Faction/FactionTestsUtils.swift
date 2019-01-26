@testable import App
import Vapor
import FluentPostgreSQL

final class FactionTestsUtils {

    static func createFaction(armyId: Int, app: Application) throws -> (request: CreateFactionRequest, response: Faction) {
        let request = CreateFactionRequest(name: "Khorne",
                                           rules: [AddRuleRequest(name: "Khorne Loci", description: "Can reroll charge")])
        let response = try app.getResponse(to: "armies/\(armyId)/factions",
                                           method: .POST,
                                           headers: ["Content-Type": "application/json"],
                                           data: request,
                                           decodeTo: Faction.self)

        return (request, response)
    }

}
