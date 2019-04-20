import Vapor
import FluentPostgreSQL

final class SelectedModelWeapon: PostgreSQLModel {
    var id: Int?
    var modelId: Int
    var weaponBucketId: Int
    var weaponId: Int

    init(modelId: Int, weaponBucketId: Int, weaponId: Int) {
        self.modelId = modelId
        self.weaponBucketId = weaponBucketId
        self.weaponId = weaponId
    }
}

extension SelectedModelWeapon: Content { }
