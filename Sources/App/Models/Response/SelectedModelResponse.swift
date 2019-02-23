import Vapor

struct SelectedModelResponse: Content {
    let id: Int
    let cost: Int
    let model: ModelResponse
    let selectedWeapons: [Weapon]

    init(selectedModel: SelectedModel,
         model: ModelResponse,
         selectedWeapons: [Weapon]) throws {
        self.id = try selectedModel.requireID()
        self.cost = model.cost + selectedWeapons.reduce(0) { $0 + $1.cost }
        self.model = model
        self.selectedWeapons = selectedWeapons
    }
}
