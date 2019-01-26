import Vapor

struct CreateFactionRequest: Content {
    var name: String
    var rules: [AddRuleRequest]
}
