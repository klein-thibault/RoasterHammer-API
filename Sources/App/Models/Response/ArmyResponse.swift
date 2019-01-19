import Vapor
import FluentPostgreSQL

final class ArmyResponse: Content {
    let id: Int
    let name: String
    let detachments: [DetachmentResponse]
    let rules: [Rule]

    init(army: Army, detachments: [DetachmentResponse], rules: [Rule]) throws {
        self.id = try army.requireID()
        self.name = army.name
        self.detachments = detachments
        self.rules = rules
    }
}
