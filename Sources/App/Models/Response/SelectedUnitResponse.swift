import Vapor

struct SelectedUnitResponse: Content {
    let id: Int
    let unit: UnitResponse
    let selectedWeapons: [Weapon]

    init(selectedUnit: SelectedUnit, unit: UnitResponse, selectedWeapons: [Weapon]) throws {
        self.id = try selectedUnit.requireID()
        self.unit = unit
        self.selectedWeapons = selectedWeapons
    }
}
