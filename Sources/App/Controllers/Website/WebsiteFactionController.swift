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

    func editFactionHandler(_ req: Request) throws -> Future<View> {
        let factionId = try req.parameters.next(Int.self)
        let armiesFuture = try ArmyController().armies(req)
        let factionFuture = try FactionController().getFaction(byID: factionId, conn: req)

        return flatMap(to: View.self, armiesFuture, factionFuture, { (armies, faction) in
            let context = EditFactionContext(title: "Edit Faction", faction: faction, armies: armies)
            return try req.view().render("createFaction", context)
        })
    }

    func editFactionPostHandler(_ req: Request, editFactionRequest: CreateFactionAndRulesData) throws -> Future<Response> {
        let factionId = try req.parameters.next(Int.self)
        let rules = WebRequestUtils().addRuleRequest(forRuleData: editFactionRequest.rules)
        let editFaction = EditFactionRequest(name: editFactionRequest.factionName,
                                             rules: rules,
                                             armyId: editFactionRequest.armyId)

        return FactionController()
            .editFaction(factionId: factionId, request: editFaction, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer"))
    }

}
