import Vapor

struct SelectedUnitResponse: Content {
    let id: Int
    let unit: UnitResponse
    let models: [SelectedModelResponse]

    init(selectedUnit: SelectedUnit,
         unit: UnitResponse,
         models: [SelectedModelResponse]) throws {
        self.id = try selectedUnit.requireID()
        self.unit = unit
        self.models = models
    }
}
