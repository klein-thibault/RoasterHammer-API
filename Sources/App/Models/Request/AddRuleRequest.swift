import Vapor

struct AddRuleRequest: Content {
    var name: String
    var description: String
}
