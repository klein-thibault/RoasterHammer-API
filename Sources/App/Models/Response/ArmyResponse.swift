import Vapor
import FluentPostgreSQL

final class ArmyResponse: Content {
    let id: Int
    let name: String
    let rules: [Rule]

    init(army: Army, rules: [Rule]) throws {
        self.id = try army.requireID()
        self.name = army.name
        self.rules = rules
    }
}
