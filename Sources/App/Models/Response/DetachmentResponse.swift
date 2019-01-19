import Vapor

struct DetachmentResponse: Content {
    let id: Int
    let name: String
    let commandPoints: Int
    let roles: [Role]

    init(detachment: Detachment, roles: [Role]) throws {
        self.id = try detachment.requireID()
        self.name = detachment.name
        self.commandPoints = detachment.commandPoints
        self.roles = roles
    }
}
