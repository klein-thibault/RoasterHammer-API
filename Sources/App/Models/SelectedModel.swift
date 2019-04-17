import Vapor
import FluentPostgreSQL

final class SelectedModel: PostgreSQLModel {
    var id: Int?
    var modelId: Int
    // TODO: to remove, replaced by weaponBuckets
    var weapons: Siblings<SelectedModel, Weapon, SelectedModelWeapon> {
        return siblings()
    }
    var weaponBuckets: Siblings<SelectedModel, WeaponBucket, SelectedModelWeaponBucket> {
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
