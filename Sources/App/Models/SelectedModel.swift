import Vapor
import FluentPostgreSQL

final class SelectedModel: PostgreSQLModel {
    var id: Int?
    var modelId: Int
    var quantity: Int
    var weapons: Siblings<SelectedModel, Weapon, SelectedModelWeapon> {
        return siblings()
    }
    var units: Siblings<SelectedModel, SelectedUnit, SelectedUnitModel> {
        return siblings()
    }

    init(modelId: Int, quantity: Int) {
        self.modelId = modelId
        self.quantity = quantity
    }
}

extension SelectedModel: Content { }
