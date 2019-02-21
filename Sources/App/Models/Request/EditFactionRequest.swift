import Vapor

struct EditFactionRequest: Content {
    var name: String?
    var rules: [AddRuleRequest]?
    var armyId: Int?

    init(name: String?, rules: [AddRuleRequest]?, armyId: Int?) {
        self.name = name
        self.rules = rules
        self.armyId = armyId
    }
}
