import Vapor

struct SelectedUnitResponse: Content {
    let id: Int
    let cost: Int
    let unit: UnitResponse
    let models: [SelectedModelResponse]

    init(selectedUnit: SelectedUnit,
         unit: UnitResponse,
         models: [SelectedModelResponse]) throws {
        self.id = try selectedUnit.requireID()
        self.cost = models.reduce(0) { $0 + $1.cost }
        self.unit = unit
        self.models = models
    }
}
