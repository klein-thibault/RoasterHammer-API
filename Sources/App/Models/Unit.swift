import Vapor
import FluentPostgreSQL

final class Unit: PostgreSQLModel {
    var id: Int?
    var name: String
    var cost: Int
    var isUnique: Bool
    var minQuantity: Int
    var maxQuantity: Int
    var unitTypeId: Int
    var armyId: Int
    var army: Parent<Unit, Army> {
        return parent(\.armyId)
    }
    var models: Siblings<Unit, Model, UnitModel> {
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

    init(name: String,
         cost: Int,
         isUnique: Bool,
         minQuantity: Int,
         maxQuantity: Int,
         unitTypeId: Int,
         armyId: Int) {
        self.name = name
        self.cost = cost
        self.isUnique = isUnique
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.unitTypeId = unitTypeId
        self.armyId = armyId
    }

}

extension Unit: Content { }
extension Unit: PostgreSQLMigration { }
