import Vapor
import FluentPostgreSQL

final class SelectedModel: PostgreSQLModel {
    var id: Int?
    var modelId: Int
    var weapons: Siblings<SelectedModel, Weapon, SelectedModelWeapon> {
        return siblings()
    }
    var units: Siblings<SelectedModel, SelectedUnit, SelectedUnitModel> {
        return siblings()
    }

    init(modelId: Int) {
        self.modelId = modelId
    }
}

extension SelectedModel: Content { }
