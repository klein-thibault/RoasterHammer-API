import Vapor
import FluentPostgreSQL

final class Army: PostgreSQLModel {

    var id: Int?
    var name: String
    var roasters: Siblings<Army, Roaster, RoasterArmy> {
        return siblings()
    }
    var detachments: Siblings<Army, Detachment, ArmyDetachment> {
        return siblings()
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
