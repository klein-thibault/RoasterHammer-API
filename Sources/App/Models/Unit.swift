import Vapor
import FluentPostgreSQL

final class Unit: PostgreSQLModel {
    var id: Int?
    var name: String
    var isUnique: Bool
    var minQuantity: Int
    var maxQuantity: Int
    var unitTypeId: Int
    var armyId: Int
    var minPsychicPowerQuantity: Int
    var maxPsychicPowerQuantity: Int
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
    var availableWarlordTrait: Siblings<Unit, WarlordTrait, UnitWarlordTrait> {
        return siblings()
    }
    var unitType: Parent<Unit, UnitType> {
        return parent(\.unitTypeId)
    }
    var availablePsychicPower: Siblings<Unit, PsychicPower, UnitPsychicPower> {
        return siblings()
    }

    init(name: String,
         isUnique: Bool,
         minQuantity: Int,
         maxQuantity: Int,
         unitTypeId: Int,
         armyId: Int,
         minPsychicPowerQuantity: Int,
         maxPsychicPowerQuantity: Int) {
        self.name = name
        self.isUnique = isUnique
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.unitTypeId = unitTypeId
        self.armyId = armyId
        self.minPsychicPowerQuantity = minPsychicPowerQuantity
        self.maxPsychicPowerQuantity = maxPsychicPowerQuantity
    }

}

extension Unit: Content { }
extension Unit: PostgreSQLMigration { }
