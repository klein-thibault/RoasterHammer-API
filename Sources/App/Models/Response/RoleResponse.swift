import Vapor

struct RoleResponse: Content {
    let id: Int
    let name: String
    let units: [Unit]

    init(role: Role, units: [Unit]) throws {
        self.id = try role.requireID()
        self.name = role.name
        self.units = units
    }
}
