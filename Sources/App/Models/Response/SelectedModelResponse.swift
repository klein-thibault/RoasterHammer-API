import Vapor

struct SelectedModelResponse: Content {
    let id: Int
    let model: ModelResponse
    let selectedWeapons: [Weapon]

    init(selectedModel: SelectedModel,
         model: ModelResponse,
         selectedWeapons: [Weapon]) throws {
        self.id = try selectedModel.requireID()
        self.model = model
        self.selectedWeapons = selectedWeapons
    }
}
