import Vapor

struct CreateWeaponRequest: Content {
    var name: String
    var range: String
    var type: String
    var strength: String
    var armorPiercing: String
    var damage: String
    var cost: Int
}
