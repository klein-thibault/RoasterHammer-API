import Vapor
import FluentPostgreSQL

final class SelectedUnit: PostgreSQLModel {
    var id: Int?
    var unitId: Int
    var quantity: Int
    var isWarlord: Bool
    var warlordTraitId: Int?
    var relicId: Int?
    var roles: Siblings<SelectedUnit, Role, UnitRole> {
        return siblings()
    }
    var models: Siblings<SelectedUnit, SelectedModel, SelectedUnitModel> {
        return siblings()
    }
    var psychicPowers: Siblings<SelectedUnit, PsychicPower, SelectedUnitPsychicPower> {
        return siblings()
    }

    init(unitId: Int, quantity: Int, isWarlord: Bool) {
        self.unitId = unitId
        self.quantity = quantity
        self.isWarlord = isWarlord
    }
}

extension SelectedUnit: Content { }
