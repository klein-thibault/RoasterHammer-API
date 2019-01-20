import Vapor

struct DetachmentResponse: Content {
    let id: Int
    let name: String
    let commandPoints: Int
    let roles: [RoleResponse]
    let army: ArmyResponse

    init(detachment: Detachment, roles: [RoleResponse], army: ArmyResponse) throws {
        self.id = try detachment.requireID()
        self.name = detachment.name
        self.commandPoints = detachment.commandPoints
        self.roles = roles
        self.army = army
    }
}
