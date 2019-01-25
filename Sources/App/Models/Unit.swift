import Vapor
import FluentPostgreSQL

final class Unit: PostgreSQLModel {
    var id: Int?
    var name: String
    var cost: Int
    var isUnique: Bool
    var unitTypeId: Int
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
    var unitType: Parent<Unit, UnitType> {
        return parent(\.unitTypeId)
    }

    init(name: String, cost: Int, isUnique: Bool, unitTypeId: Int) {
        self.name = name
        self.cost = cost
        self.isUnique = isUnique
        self.unitTypeId = unitTypeId
    }

}

extension Unit: Content { }
extension Unit: PostgreSQLMigration { }
