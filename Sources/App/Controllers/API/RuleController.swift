import Vapor
import RoasterHammer_Shared

final class RuleController {

    func ruleResponse(forRule rule: Rule) -> RuleResponse {
        return RuleResponse(name: rule.name, description: rule.description)
    }

    func rulesResponse(forRules rules: [Rule]) -> [RuleResponse] {
        return rules.map { self.ruleResponse(forRule: $0) }
    }

}
