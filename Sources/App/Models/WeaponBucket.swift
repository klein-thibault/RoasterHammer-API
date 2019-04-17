import Vapor
import FluentPostgreSQL

final class WeaponBucket: PostgreSQLModel {
    var id: Int?
    var name: String
    var models: Siblings<WeaponBucket, SelectedModel, SelectedModelWeaponBucket> {
        return siblings()
    }
    var weapons: Siblings<WeaponBucket, Weapon, WeaponBucketWeapon> {
        return siblings()
    }

    init(name: String) {
        self.name = name
    }
}

extension WeaponBucket: Content { }
extension WeaponBucket: PostgreSQLMigration { }
