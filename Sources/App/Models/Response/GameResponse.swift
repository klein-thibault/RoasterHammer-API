import Vapor

struct GameResponse: Content {
    let id: Int
    let name: String
    let version: Int
    let roasters: [Roaster]
    let rules: [Rule]

    init(game: Game, roasters: [Roaster], rules: [Rule]) throws {
        self.id = try game.requireID()
        self.name = game.name
        self.version = game.version
        self.roasters = roasters
        self.rules = rules
    }
}
