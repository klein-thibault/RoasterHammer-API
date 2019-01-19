import Vapor

struct CreateRuleRequest: Content {
    let name: String
    let description: String
}
