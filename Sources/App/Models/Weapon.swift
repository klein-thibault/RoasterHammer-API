import Vapor
import FluentPostgreSQL

final class Weapon: PostgreSQLModel {
    var id: Int?
    var name: String
    var range: String
    var type: String
    var strength: String
    var armorPiercing: String
    var damage: String
    var cost: Int
    var units: Siblings<Weapon, Unit, UnitWeapon> {
        return siblings()
    }

    init(name: String,
        range: String,
        type: String,
        strength: String,
        armorPiercing: String,
        damage: String,
        cost: Int) {
        self.name = name
        self.range = range
        self.type = type
        self.strength = strength
        self.armorPiercing = armorPiercing
        self.damage = damage
        self.cost = cost
    }
}

extension Weapon: Content { }
extension Weapon: PostgreSQLMigration { }
