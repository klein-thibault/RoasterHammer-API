import Vapor
import FluentPostgreSQL

final class Faction: PostgreSQLModel {
    var id: Int?
    var name: String
    var armyId: Int
    var army: Parent<Faction, Army> {
        return parent(\.armyId)
    }
    var rules: Siblings<Faction, Rule, FactionRule> {
        return siblings()
    }

    init(name: String, armyId: Int) {
        self.name = name
        self.armyId = armyId
    }
}

extension Faction: Content { }
extension Faction: PostgreSQLMigration { }
