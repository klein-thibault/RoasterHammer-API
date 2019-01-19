import Vapor

struct UnitResponse: Content {
    let id: Int
    let name: String
    let cost: Int
    let characteristics: Characteristics

    init(unit: Unit, characteristics: Characteristics) throws {
        self.id = try unit.requireID()
        self.name = unit.name
        self.cost = unit.cost
        self.characteristics = characteristics
    }
}
