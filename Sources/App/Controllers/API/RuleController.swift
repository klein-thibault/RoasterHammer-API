import Vapor
import RoasterHammer_Shared

final class RuleController {

    func ruleResponse(forRule rule: Rule) -> RuleResponse {
        return RuleResponse(name: rule.name, description: rule.description)
    }

    func rulesResponse(forRules rules: [Rule]) -> [RuleResponse] {
        return rules.map { self.ruleResponse(forRule: $0) }
    }

    func createRule(request: AddRuleRequest, conn: DatabaseConnectable) -> Future<Rule> {
        return Rule(name: request.name, description: request.description).save(on: conn)
    }

    func getAllRules(conn: DatabaseConnectable) -> Future<[Rule]> {
        return Rule.query(on: conn).all()
    }

    func getRuleByID(_ id: Int, conn: DatabaseConnectable) -> Future<Rule> {
        return Rule.find(id, on: conn).unwrap(or: RoasterHammerError.ruleIsMissing.error())
    }

}
