import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteRuleController {
    func rulesHandler(_ req: Request) throws -> Future<View> {
        return RuleController()
            .getAllRules(conn: req)
            .flatMap(to: View.self, { rules in
                let context = RulesContext(title: "Rules", rules: rules)
                return try req.view().render("rules", context)
            })
    }

    func ruleHandler(_ req: Request) throws -> Future<View> {
        let ruleId = try req.parameters.next(Int.self)

        return RuleController()
            .getRuleByID(ruleId, conn: req)
            .flatMap(to: View.self, { rule in
                let context = RuleContext(rule: rule, editing: false)
                return try req.view().render("rule", context)
            })
    }

    func editRuleHandler(_ req: Request) throws -> Future<View> {
        let ruleId = try req.parameters.next(Int.self)
        return RuleController()
            .getRuleByID(ruleId, conn: req)
            .flatMap(to: View.self, { rule in
                let context = RuleContext(rule: rule, editing: true)
                return try req.view().render("rule", context)
            })
    }
}
