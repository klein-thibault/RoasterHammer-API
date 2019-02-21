import Vapor

struct FactionResponse: Content {
    let id: Int
    let name: String
    let rules: [Rule]

    init(faction: Faction, rules: [Rule]) throws {
        self.id = try faction.requireID()
        self.name = faction.name
        self.rules = rules
    }
}
