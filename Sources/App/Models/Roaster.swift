import Vapor
import FluentPostgreSQL

final class Roaster: PostgreSQLModel {
    var id: Int?
    var name: String
    var version: Int
    var gameId: Int
    var game: Parent<Roaster, Game> {
        return parent(\.gameId)
    }
    var rules: Siblings<Roaster, Rule, RoasterRule> {
        return siblings()
    }
    var users: Siblings<Roaster, Customer, UserRoaster> {
        return siblings()
    }

    init(name: String, version: Int, gameId: Int) {
        self.name = name
        self.version = version
        self.gameId = gameId
    }
}

extension Roaster: Content { }
extension Roaster: PostgreSQLMigration { }
