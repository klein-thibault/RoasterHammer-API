import Vapor
import FluentPostgreSQL

final class Model: PostgreSQLModel {
    var id: Int?
    var name: String
    var minQuantity: Int
    var maxQuantity: Int
    var weaponQuantity: Int
    var characteristics: Children<Model, Characteristics> {
        return children(\.modelId)
    }
    var weapons: Siblings<Model, Weapon, ModelWeapon> {
        return siblings()
    }

    init(name: String,
         minQuantity: Int,
         maxQuantity: Int,
         weaponQuantity: Int) {
        self.name = name
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.weaponQuantity = weaponQuantity
    }
}

extension Model: Content { }
extension Model: PostgreSQLMigration { }
