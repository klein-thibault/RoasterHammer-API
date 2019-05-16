import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteRelicController {

    // MARK: - Public Functions

    func relicsHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return try ArmyController().getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = RelicContext(army: army)
                return try req.view().render("relics", context)
            })
    }

    func createRelicHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let weaponsFuture = WeaponController().getAllWeapons(conn: req)

        return weaponsFuture.flatMap(to: View.self, { weapons in
            let context = CreateRelicContext(title: "Create New Relic", armyId: armyId, weapons: weapons)
            return try req.view().render("createRelic", context)
        })
    }

    func createRelicPostHandler(_ req: Request,
                                createRelicData: CreateRelicData) throws -> Future<Response> {
        let weaponId = createRelicData.weaponCheckbox.keys.compactMap { $0.intValue }.first
        let keywordsFuture = KeywordController().getKeywordsWithNames(createRelicData.keywords ?? [], conn: req)

        return keywordsFuture
            .flatMap(to: Relic.self, { keywords in
                let keywordIds = try keywords.map { try $0.requireID() }
                let request = AddRelicRequest(name: createRelicData.name,
                                              description: createRelicData.description,
                                              weaponId: weaponId,
                                              keywordIds: keywordIds)
                return RelicController().createRelic(request: request, armyId: createRelicData.armyId, conn: req)
            })
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(createRelicData.armyId)/relics"))
    }

}
