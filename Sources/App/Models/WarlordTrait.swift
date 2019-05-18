import Vapor
import FluentPostgreSQL

final class WarlordTrait: PostgreSQLModel {
    var id: Int?
    var name: String
    var description: String
    var armyId: Int
    var army: Parent<WarlordTrait, Army> {
        return parent(\.armyId)
    }

    init(name: String, description: String, armyId: Int) {
        self.name = name
        self.description = description
        self.armyId = armyId
    }
}

extension WarlordTrait: Content { }
extension WarlordTrait: PostgreSQLMigration { }
