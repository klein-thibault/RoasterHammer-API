import Vapor
import Leaf

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

}
