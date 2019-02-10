import Vapor

struct CreateWeaponRequest: Content {
    let name: String
    let range: String
    let type: String
    let strength: String
    let armorPiercing: String
    let damage: String
    let cost: Int
    let ability: String

    init(name: String,
         range: String,
         type: String,
         strength: String,
         armorPiercing: String,
         damage: String,
         cost: Int,
         ability: String) {
        self.name = name
        self.range = range
        self.type = type
        self.strength = strength
        self.armorPiercing = armorPiercing
        self.damage = damage
        self.cost = cost
        self.ability = ability
    }
}
