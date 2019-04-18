import Vapor
import FluentPostgreSQL

final class Model: PostgreSQLModel {
    var id: Int?
    var name: String
    var minQuantity: Int
    var maxQuantity: Int
    var weaponQuantity: Int
    var cost: Int
    var characteristics: Children<Model, Characteristics> {
        return children(\.modelId)
    }
    // TODO: to remove, replaced by weaponBuckets
    var weapons: Siblings<Model, Weapon, ModelWeapon> {
        return siblings()
    }
    var weaponBuckets: Siblings<Model, WeaponBucket, ModelWeaponBucket> {
        return siblings()
    }

    init(name: String,
         cost: Int,
         minQuantity: Int,
         maxQuantity: Int,
         weaponQuantity: Int) {
        self.name = name
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.weaponQuantity = weaponQuantity
        self.cost = cost
    }
}

extension Model: Content { }
extension Model: PostgreSQLMigration { }
