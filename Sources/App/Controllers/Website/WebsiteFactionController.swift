import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteFactionController {

    func createFactionHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)

        return try ArmyController()
            .getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = CreateFactionContext(title: "Create A Faction", army: army)
                return try req.view().render("createFaction", context)
            })
    }

    func createFactionPostHandler(_ req: Request, createFactionRequest: CreateFactionAndRulesData) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let rules = WebRequestUtils().addRuleRequest(forRuleData: createFactionRequest.rules)
        let newFactionRequest = CreateFactionRequest(name: createFactionRequest.factionName, rules: rules)

        return FactionController()
            .createFaction(armyId: armyId,
                           request: newFactionRequest,
                           conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer/armies/\(armyId)")
            })
    }

    func editFactionHandler(_ req: Request) throws -> Future<View> {
        _ = try req.parameters.next(Int.self)
        let factionId = try req.parameters.next(Int.self)
        return try FactionController().getFaction(byID: factionId, conn: req)
            .flatMap(to: View.self, { faction in
                let context = EditFactionContext(title: "Edit Faction", faction: faction)
                return try req.view().render("createFaction", context)
            })
    }

    func editFactionPostHandler(_ req: Request, editFactionRequest: CreateFactionAndRulesData) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let factionId = try req.parameters.next(Int.self)
        let rules = WebRequestUtils().addRuleRequest(forRuleData: editFactionRequest.rules)
        let editFaction = EditFactionRequest(name: editFactionRequest.factionName,
                                             rules: rules,
                                             armyId: armyId)

        return FactionController()
            .editFaction(factionId: factionId, request: editFaction, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)"))
    }

    func deleteFactionHandler(_ req: Request) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let factionId = try req.parameters.next(Int.self)
        return FactionController()
        .deleteFaction(factionId: factionId, conn: req)
        .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)"))
    }

}
