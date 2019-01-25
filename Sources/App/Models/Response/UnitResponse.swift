import Vapor

struct UnitResponse: Content {
    let id: Int
    let name: String
    let cost: Int
    let characteristics: Characteristics
    let weapons: [Weapon]
    let keywords: [String]

    init(unit: Unit,
         characteristics: Characteristics,
         weapons: [Weapon],
         keywords: [String]) throws {
        self.id = try unit.requireID()
        self.name = unit.name
        self.cost = unit.cost
        self.characteristics = characteristics
        self.weapons = weapons
        self.keywords = keywords
    }
}
