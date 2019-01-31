import Vapor

struct CreateArmyRequest: Content {
    let name: String
    let rules: [AddRuleRequest]
}
