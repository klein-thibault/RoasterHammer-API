import Vapor
import FluentPostgreSQL

final class Game: PostgreSQLModel {
    var id: Int?
    var name: String
    var version: Int
    var roasters: Children<Game, Roaster> {
        return children(\.gameId)
    }
    var rules: Siblings<Game, Rule, GameRule> {
        return siblings()
    }

    init(name: String, version: Int) {
        self.name = name
        self.version = version
    }
}

extension Game: Content { }
extension Game: PostgreSQLMigration { }
