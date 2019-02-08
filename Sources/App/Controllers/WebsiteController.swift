import Vapor
import Leaf

struct WebsiteController {

    func indexHandler(_ req: Request) throws -> Future<View> {
        let armyController = ArmyController()
        return try armyController.armies(req).flatMap(to: View.self, { armies in
            let context = IndexContext(title: "Homepage", armies: armies)
            return try req.view().render("index", context)
        })
    }

    func unitsHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return UnitController()
            .getUnits(armyId: armyId, conn: req)
            .flatMap(to: View.self, { units in
            let context = UnitsContext(title: "Units", units: units)
            return try req.view().render("units", context)
        })
    }

    func createArmyHandler(_ req: Request) throws -> Future<View> {
        let context = CreateArmyContext(title: "Create An Army")
        return try req.view().render("createArmy", context)
    }

    func createArmyPostHandler(_ req: Request, createArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        var rules: [AddRuleRequest] = []
        for ruleDictionary in createArmyRequest.rules.values {
            if let ruleName = ruleDictionary["name"], ruleName.count > 0,
                let ruleDescription = ruleDictionary["description"], ruleDescription.count > 0 {
                let rule = AddRuleRequest(name: ruleName,
                                          description: ruleDescription)
                rules.append(rule)
            }
        }

        let createArmyRequest = CreateArmyRequest(name: createArmyRequest.armyName,
                                                  rules: rules)

        return ArmyController()
            .createArmy(request: createArmyRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

}

struct IndexContext: Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct UnitsContext: Encodable {
    let title: String
    let units: [UnitResponse]
}

struct CreateArmyContext: Encodable {
    let title: String
}

typealias NewRuleContext = [String: String]

struct CreateArmyAndRulesData: Content {
    let armyName: String
    let rules: [String: NewRuleContext]
}
