import Vapor

struct CreateFactionRequest: Content {
    var name: String
    var rules: [AddRuleRequest]

    init(name: String, rules: [AddRuleRequest]) {
        self.name = name
        self.rules = rules
    }
}
