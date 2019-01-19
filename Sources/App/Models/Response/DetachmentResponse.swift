import Vapor

struct DetachmentResponse: Content {
    let id: Int
    let name: String
    let commandPoints: Int
    let roles: [RoleResponse]

    init(detachment: Detachment, roles: [RoleResponse]) throws {
        self.id = try detachment.requireID()
        self.name = detachment.name
        self.commandPoints = detachment.commandPoints
        self.roles = roles
    }
}
