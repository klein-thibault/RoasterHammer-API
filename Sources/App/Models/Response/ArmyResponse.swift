import Vapor
import FluentPostgreSQL

final class ArmyResponse: Content {
    let id: Int
    let name: String
    let factions: [FactionResponse]
    let rules: [Rule]

    init(army: Army, factions: [FactionResponse], rules: [Rule]) throws {
        self.id = try army.requireID()
        self.name = army.name
        self.factions = factions
        self.rules = rules
    }
}
