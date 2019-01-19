import Vapor

struct RoleResponse: Content {
    let id: Int
    let name: String
    let units: [UnitResponse]

    init(role: Role, units: [UnitResponse]) throws {
        self.id = try role.requireID()
        self.name = role.name
        self.units = units
    }
}
