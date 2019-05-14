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
        let context = CreateRelicContext(armyId: armyId)
        return try req.view().render("createRelic", context)
    }

}
