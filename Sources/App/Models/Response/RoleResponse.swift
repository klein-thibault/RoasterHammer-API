import Vapor

struct RoleResponse: Content {
    let id: Int
    let name: String
    let units: [SelectedUnitResponse]

    init(role: Role, units: [SelectedUnitResponse]) throws {
        self.id = try role.requireID()
        self.name = role.name
        self.units = units
    }
}
