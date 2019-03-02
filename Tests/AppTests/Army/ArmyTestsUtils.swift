@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class ArmyTestsUtils {

    static func createArmy(app: Application) throws -> (request: CreateArmyRequest, response: Army) {
        let rules = [AddRuleRequest(name: "Death to the False Emporer",
                                    description: "Every hit of 6 generates a new attack")]
        let request = CreateArmyRequest(name: "Chaos Space Marines", rules: rules)
        let army = try app.getResponse(to: "armies",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: request,
                                       decodeTo: Army.self)

        return (request, army)
    }

    static func createArmyWithFaction(app: Application) throws -> (request: CreateArmyRequest, response: Army) {
        let (request, army) = try createArmy(app: app)
        let createFactionRequest = CreateFactionRequest(name: "Khorne",
                                                        rules: [AddRuleRequest(name: "Khorne Loci",
                                                                               description: "Can reroll charge")])
        try app.sendRequest(to: "armies/\(army.requireID())/factions",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: createFactionRequest)

        return (request, army)
    }

}
