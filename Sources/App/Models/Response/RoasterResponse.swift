import Vapor

struct RoasterResponse: Content {
    let id: Int
    let name: String
    let version: Int
    let detachments: [DetachmentResponse]
    let rules: [Rule]

    init(roaster: Roaster, detachments: [DetachmentResponse], rules: [Rule]) throws {
        self.id = try roaster.requireID()
        self.name = roaster.name
        self.version = roaster.version
        self.detachments = detachments
        self.rules = rules
    }
}
