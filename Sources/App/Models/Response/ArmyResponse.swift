import Vapor
import FluentPostgreSQL

final class ArmyResponse: Content {
    let id: Int
    let name: String
    let detachments: [Detachment]
    let rules: [Rule]

    init(army: Army, detachments: [Detachment], rules: [Rule]) throws {
        self.id = try army.requireID()
        self.name = army.name
        self.detachments = detachments
        self.rules = rules
    }
}
