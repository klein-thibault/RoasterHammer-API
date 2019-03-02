import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteArmyController {

    func armyHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let armyFuture = try ArmyController().getArmy(byID: armyId, conn: req)
        let unitsFuture = UnitController().getUnits(armyId: armyId, conn: req)

        return flatMap(to: View.self, armyFuture, unitsFuture, { (army, units) in
            let context = ArmyContext(army: army, units: units)
            return try req.view().render("army", context)
        })
    }

    func createArmyHandler(_ req: Request) throws -> Future<View> {
        let context = CreateArmyContext(title: "Create An Army")
        return try req.view().render("createArmy", context)
    }

    func createArmyPostHandler(_ req: Request, createArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        let rules = WebRequestUtils().addRuleRequest(forRuleData: createArmyRequest.rules)
        let newArmyRequest = CreateArmyRequest(name: createArmyRequest.armyName,
                                               rules: rules)

        return ArmyController()
            .createArmy(request: newArmyRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

    func editArmyHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)

        return try ArmyController().getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = EditArmyContext(title: "Edit Army", army: army)
                return try req.view().render("createArmy", context)
            })
    }

    func editArmyPostHandler(_ req: Request, editArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let rules = WebRequestUtils().addRuleRequest(forRuleData: editArmyRequest.rules)
        let editArmy = EditArmyRequest(name: editArmyRequest.armyName, rules: rules)

        return ArmyController()
            .editArmy(armyId: armyId, request: editArmy, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)"))
    }

    func deleteArmyHandler(_ req: Request) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        return ArmyController()
            .deleteArmy(armyId: armyId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer"))
    }

}
