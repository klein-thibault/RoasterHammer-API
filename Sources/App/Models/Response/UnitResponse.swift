import Vapor

struct UnitResponse: Content {
    let id: Int
    let name: String
    let cost: Int
    let isUnique: Bool
    let minQuantity: Int
    let maxQuantity: Int
    let weaponQuantity: Int
    let unitType: String
    let characteristics: Characteristics
    let weapons: [WeaponResponse]
    let keywords: [String]
    let rules: [Rule]

    init(unit: Unit,
         unitType: String,
         characteristics: Characteristics,
         weapons: [WeaponResponse],
         keywords: [String],
         rules: [Rule]) throws {
        self.id = try unit.requireID()
        self.name = unit.name
        self.cost = unit.cost
        self.isUnique = unit.isUnique
        self.minQuantity = unit.minQuantity
        self.maxQuantity = unit.maxQuantity
        self.weaponQuantity = unit.weaponQuantity
        self.unitType = unitType
        self.characteristics = characteristics
        self.weapons = weapons
        self.keywords = keywords
        self.rules = rules
    }
}
