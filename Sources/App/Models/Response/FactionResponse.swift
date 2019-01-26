import Vapor

struct FactionResponse: Content {
    let name: String
    let rules: [Rule]

    init(faction: Faction, rules: [Rule]) {
        self.name = faction.name
        self.rules = rules
    }
}
