import Vapor
import RoasterHammer_Shared

final class RuleController {

    // MARK: - Public Functions

    func getRules(_ req: Request) -> Future<[Rule]> {
        return getAllRules(conn: req)
    }

    func getRuleById(_ req: Request) throws -> Future<Rule> {
        let ruleId = try req.parameters.next(Int.self)
        return getRuleByID(ruleId, conn: req)
    }

    func createRule(_ req: Request) throws -> Future<Rule> {
        return try req.content.decode(AddRuleRequest.self)
            .flatMap(to: Rule.self, { request in
                return self.createRule(request: request, conn: req)
            })
    }

    func deleteRule(_ req: Request) throws -> Future<HTTPStatus> {
        let ruleId = try req.parameters.next(Int.self)

        return deleteRuleByID(ruleId, conn: req)
            .transform(to: HTTPStatus.ok)
    }

    // MARK: - Utilities Functions

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

    func deleteRuleByID(_ id: Int, conn: DatabaseConnectable) -> Future<Void> {
        return Rule.find(id, on: conn).unwrap(or: RoasterHammerError.ruleIsMissing.error())
            .flatMap { rule in
                rule.delete(on: conn)
            }
    }

}
