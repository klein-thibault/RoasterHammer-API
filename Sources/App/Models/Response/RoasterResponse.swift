import Vapor

struct RoasterResponse: Content {
    let id: Int
    let name: String
    let version: Int
    let armies: [Army]
    let rules: [Rule]

    init(roaster: Roaster, armies: [Army], rules: [Rule]) throws {
        self.id = try roaster.requireID()
        self.name = roaster.name
        self.version = roaster.version
        self.armies = armies
        self.rules = rules
    }
}
