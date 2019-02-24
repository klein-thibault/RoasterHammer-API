import Vapor
import RoasterHammer_Shared

struct DetachmentResponse: Content {
    let id: Int
    let name: String
    let commandPoints: Int
    let selectedFaction: FactionResponse?
    let roles: [RoleResponse]
    let army: ArmyResponse

    init(detachment: Detachment,
         selectedFaction: FactionResponse?,
         roles: [RoleResponse],
         army: ArmyResponse) throws {
        self.id = try detachment.requireID()
        self.name = detachment.name
        self.commandPoints = detachment.commandPoints
        self.selectedFaction = selectedFaction
        self.roles = roles
        self.army = army
    }
}

struct DetachmentShortResponse: Content {
    let name: String
    let commandPoints: Int

    init(name: String, commandPoints: Int) {
        self.name = name
        self.commandPoints = commandPoints
    }
}
