import Vapor

struct UnitResponse: Content {
    let id: Int
    let name: String
    let cost: Int
    let isUnique: Bool
    let unitType: String
    let characteristics: Characteristics
    let weapons: [Weapon]
    let keywords: [String]

    init(unit: Unit,
         unitType: String,
         characteristics: Characteristics,
         weapons: [Weapon],
         keywords: [String]) throws {
        self.id = try unit.requireID()
        self.name = unit.name
        self.cost = unit.cost
        self.isUnique = unit.isUnique
        self.unitType = unitType
        self.characteristics = characteristics
        self.weapons = weapons
        self.keywords = keywords
    }
}
