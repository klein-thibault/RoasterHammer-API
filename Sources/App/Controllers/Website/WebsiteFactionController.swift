import Vapor
import Leaf

struct WebsiteFactionController {

    func createFactionHandler(_ req: Request) throws -> Future<View> {
        return try ArmyController().armies(req).flatMap(to: View.self, { armies in
            let context = CreateFactionContext(title: "Create A Faction", armies: armies)
            return try req.view().render("createFaction", context)
        })
    }

    func createFactionPostHandler(_ req: Request, createFactionRequest: CreateFactionAndRulesData) throws -> Future<Response> {
        let rules = WebRequestUtils().addRuleRequest(forRuleData: createFactionRequest.rules)
        let newFactionRequest = CreateFactionRequest(name: createFactionRequest.factionName, rules: rules)

        return FactionController()
            .createFaction(armyId: createFactionRequest.armyId,
                           request: newFactionRequest,
                           conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

}
