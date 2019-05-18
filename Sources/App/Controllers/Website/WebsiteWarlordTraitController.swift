import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteWarlordTraitController {

    // MARK: - Public Functions

    func warlordTraitsHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return try ArmyController().getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = WarlordTraitContext(army: army)
                return try req.view().render("warlordTraits", context)
            })
    }

    func createWarlordTraitHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let context = CreateWarlordTraitContext(title: "Create Warlord Trait", armyId: armyId)
        return try req.view().render("createWarlordTrait", context)
    }

    func createWarlordTraitPostHandler(_ req: Request,
                                       createWarlordTraitData: CreateWarlordTraitData) throws -> Future<Response> {
        let request = AddWarlordTraitRequest(name: createWarlordTraitData.name,
                                             description: createWarlordTraitData.description)
        return WarlordTraitController()
            .createWarlordTrait(request: request, armyId: createWarlordTraitData.armyId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(createWarlordTraitData.armyId)/warlord-traits"))
    }

    func deleteWarlordTraitHandler(_ req: Request) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let warlordId = try req.parameters.next(Int.self)

        return WarlordTraitController()
            .deleteWarlordTraitById(warlordId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)/warlord-traits"))
    }

}
