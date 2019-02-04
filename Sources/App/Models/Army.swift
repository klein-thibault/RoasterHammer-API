import Vapor
import FluentPostgreSQL

final class Army: PostgreSQLModel {
    var id: Int?
    var name: String
    var units: Children<Army, Unit> {
        return children(\.armyId)
    }
    var detachments: Children<Army, Detachment> {
        return children(\.armyId)
    }
    var factions: Children<Army, Faction> {
        return children(\.armyId)
    }
    var rules: Siblings<Army, Rule, ArmyRule> {
        return siblings()
    }

    init(name: String) {
        self.name = name
    }

}

extension Army: Content { }
extension Army: PostgreSQLMigration { }
