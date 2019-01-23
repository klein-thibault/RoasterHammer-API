import Vapor
import FluentPostgreSQL

final class Unit: PostgreSQLModel {
    var id: Int?
    var name: String
    var cost: Int
    var characteristics: Children<Unit, Characteristics> {
        return children(\.unitId)
    }
    var weapons: Siblings<Unit, Weapon, UnitWeapon> {
        return siblings()
    }
    var rules: Siblings<Unit, Rule, UnitRule> {
        return siblings()
    }

    init(name: String, cost: Int) {
        self.name = name
        self.cost = cost
    }

}

extension Unit: Content { }
extension Unit: PostgreSQLMigration { }
