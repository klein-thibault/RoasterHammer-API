import Vapor
import FluentPostgreSQL

final class WeaponBucket: PostgreSQLModel {
    var id: Int?
    var name: String
    var minWeaponQuantity: Int
    var maxWeaponQuantity: Int
    var models: Siblings<WeaponBucket, Model, ModelWeaponBucket> {
        return siblings()
    }
    var weapons: Siblings<WeaponBucket, Weapon, WeaponBucketWeapon> {
        return siblings()
    }

    init(name: String, minWeaponQuantity: Int, maxWeaponQuantity: Int) {
        self.name = name
        self.minWeaponQuantity = minWeaponQuantity
        self.maxWeaponQuantity = maxWeaponQuantity
    }
}

extension WeaponBucket: Content { }
extension WeaponBucket: PostgreSQLMigration { }
