import Vapor

struct UnitResponse: Content {
    let id: Int
    let name: String
    let cost: Int
    let isUnique: Bool
    let minQuantity: Int
    let maxQuantity: Int
    let unitType: String
    let army: ArmyResponse
    let models: [ModelResponse]
    let keywords: [String]
    let rules: [Rule]

    init(unit: Unit,
         unitType: String,
         army: ArmyResponse,
         models: [ModelResponse],
         keywords: [String],
         rules: [Rule]) throws {
        self.id = try unit.requireID()
        self.name = unit.name
        self.cost = unit.cost
        self.isUnique = unit.isUnique
        self.minQuantity = unit.minQuantity
        self.maxQuantity = unit.maxQuantity
        self.unitType = unitType
        self.army = army
        self.models = models
        self.keywords = keywords
        self.rules = rules
    }
}
