import Vapor
import FluentPostgreSQL

final class Unit: PostgreSQLModel {
    var id: Int?
    var name: String
    var cost: Int
    var isUnique: Bool
    var characteristics: Children<Unit, Characteristics> {
        return children(\.unitId)
    }
    var weapons: Siblings<Unit, Weapon, UnitWeapon> {
        return siblings()
    }
    var rules: Siblings<Unit, Rule, UnitRule> {
        return siblings()
    }
    var keywords: Siblings<Unit, Keyword, UnitKeyword> {
        return siblings()
    }

    init(name: String, cost: Int, isUnique: Bool) {
        self.name = name
        self.cost = cost
        self.isUnique = isUnique
    }

}

extension Unit: Content { }
extension Unit: PostgreSQLMigration { }
