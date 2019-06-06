import Vapor
import FluentPostgreSQL

final class Relic: PostgreSQLModel {
    var id: Int?
    var name: String
    var description: String
    var armyId: Int
    var army: Parent<Relic, Army> {
        return parent(\.armyId)
    }
    var weaponId: Int?
    var keywords: Siblings<Relic, Keyword, RelicKeyword> {
        return siblings()
    }

    init(name: String, description: String, armyId: Int, weaponId: Int?) {
        self.name = name
        self.description = description
        self.armyId = armyId
        self.weaponId = weaponId
    }
}

extension Relic: Content { }
extension Relic: PostgreSQLMigration { }
