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

    func createRuleHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("createRule")
    }

    func createRulePostHandler(_ req: Request, addRuleRequest: EditRuleData) throws -> Future<Response> {
        let request = AddRuleRequest(name: addRuleRequest.name, description: addRuleRequest.description)
        return RuleController().createRule(request: request, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/rules"))
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

    func editRulePostHandler(_ req: Request, editRuleRequest: EditRuleData) throws -> Future<Response> {
        let ruleId = try req.parameters.next(Int.self)
        return RuleController()
            .getRuleByID(ruleId, conn: req)
            .flatMap(to: Rule.self, { rule in
                rule.name = editRuleRequest.name
                rule.description = editRuleRequest.description
                return rule.save(on: req)
            })
            .transform(to: req.redirect(to: "/roasterhammer/rules/\(ruleId)"))
    }

    func deleteRuleHandler(_ req: Request) throws -> Future<Response> {
        let ruleId = try req.parameters.next(Int.self)
        return RuleController()
            .deleteRuleByID(ruleId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/rules"))
    }
}
