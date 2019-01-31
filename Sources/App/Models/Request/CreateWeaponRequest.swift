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
}
