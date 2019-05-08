import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteArmyController {

    // MARK: - Public Functions

    func armyHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let armyFuture = try ArmyController().getArmy(byID: armyId, conn: req)
        let unitsFuture = UnitDatabaseQueries().getUnits(armyId: armyId, unitType: nil, conn: req)

        return flatMap(to: View.self, armyFuture, unitsFuture, { (army, units) in
            let context = ArmyContext(army: army, units: units)
            return try req.view().render("army", context)
        })
    }

    func createArmyHandler(_ req: Request) throws -> Future<View> {
        let existingRulesFuture = RuleController().getAllRules(conn: req)

        return existingRulesFuture.flatMap(to: View.self, { existingRules in
            let context = CreateArmyContext(title: "Create An Army",
                                            existingRules: existingRules)
            return try req.view().render("createArmy", context)
        })
    }

    func createArmyPostHandler(_ req: Request, createArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        let rules = WebRequestUtils().addRuleRequest(forRuleData: createArmyRequest.rules)
        let newArmyRequest = CreateArmyRequest(name: createArmyRequest.armyName,
                                               rules: rules)
        let existingRuleIds = createArmyRequest.existingRuleCheckbox.keys.compactMap { $0.intValue }
        let ruleController = RuleController()
        let existingRulesFuture = existingRuleIds.map { return ruleController.getRuleByID($0, conn: req) }.flatten(on: req)

        return existingRulesFuture.flatMap(to: Response.self, { existingRules in
            return ArmyController()
                .createArmy(request: newArmyRequest, conn: req)
                .flatMap(to: [ArmyRule].self, { army in
                    return try self.assignExistingRulesToArmy(army: army, rules: existingRules, conn: req)
                })
                .transform(to: req.redirect(to: "/roasterhammer"))
        })
    }

    func editArmyHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let armyFuture = try ArmyController().getArmy(byID: armyId, conn: req)
        let existingRulesFuture = RuleController().getAllRules(conn: req)

        return flatMap(to: View.self, armyFuture, existingRulesFuture, { (army, existingRules) in
            let context = EditArmyContext(title: "Edit Army", army: army, existingRules: existingRules)
            return try req.view().render("createArmy", context)
        })
    }

    func editArmyPostHandler(_ req: Request, editArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let rules = WebRequestUtils().addRuleRequest(forRuleData: editArmyRequest.rules)
        let editArmy = EditArmyRequest(name: editArmyRequest.armyName, rules: rules)
        let existingRuleIds = editArmyRequest.existingRuleCheckbox.keys.compactMap { $0.intValue }
        let ruleController = RuleController()
        let existingRulesFuture = existingRuleIds.map { return ruleController.getRuleByID($0, conn: req) }.flatten(on: req)

        return existingRulesFuture.flatMap(to: Response.self, { existingRules in
            return ArmyController()
                .editArmy(armyId: armyId, request: editArmy, conn: req)
                .flatMap(to: [ArmyRule].self, { army in
                    return try self.assignExistingRulesToArmy(army: army, rules: existingRules, conn: req)
                })
                .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)"))
        })
    }

    func deleteArmyHandler(_ req: Request) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        return ArmyController()
            .deleteArmy(armyId: armyId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer"))
    }

    // MARK: - Private Functions

    private func assignExistingRulesToArmy(army: Army,
                                           rules: [Rule],
                                           conn: DatabaseConnectable) throws -> Future<[ArmyRule]> {
        let armyController = ArmyController()
        return rules.map { armyController.assignRule($0, toArmy: army, conn: conn) }
            .flatten(on: conn)
    }

}
