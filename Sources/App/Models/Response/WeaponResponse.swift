import Vapor
import FluentPostgreSQL

final class WeaponResponse: Content {
    let id: Int
    let name: String
    let range: String
    let type: String
    let strength: String
    let armorPiercing: String
    let damage: String
    let cost: Int
    let minQuantity: Int
    let maxQuantity: Int

    init(weapon: Weapon, minQuantity: Int, maxQuantity: Int) throws {
        self.id = try weapon.requireID()
        self.name = weapon.name
        self.range = weapon.range
        self.type = weapon.type
        self.strength = weapon.strength
        self.armorPiercing = weapon.armorPiercing
        self.damage = weapon.damage
        self.cost = weapon.cost
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
    }
}
