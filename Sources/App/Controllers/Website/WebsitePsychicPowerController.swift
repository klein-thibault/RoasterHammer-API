import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsitePsychicPowerController {

    // MARK: - Public Functions

    func psychicPowersHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return try ArmyController().getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = PsychicPowerContext(army: army)
                return try req.view().render("psychicPowers", context)
            })
    }

    func createPsychicPowerHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let context = CreatePsychicPowerContext(title: "Create Psychic Power", armyId: armyId)
        return try req.view().render("createPsychicPower", context)
    }

    func createPsychicPowerPostHandler(_ req: Request,
                                       createPsychicPowerData: CreatePsychicPowerData) throws -> Future<Response> {
        // TODO: handle keywords for psychic power creation
        let request = CreatePsychicPowerRequest(name: createPsychicPowerData.name,
                                                description: createPsychicPowerData.description,
                                                keywordIds: [])
        return PsychicPowerController()
            .createPsychicPower(request: request, armyId: createPsychicPowerData.armyId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(createPsychicPowerData.armyId)/psychic-powers"))
    }

    func deletePsychicPowerHandler(_ req: Request) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let psychicPowerId = try req.parameters.next(Int.self)

        return PsychicPowerController()
            .deletePsychicPowerById(psychicPowerId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)/psychic-powers"))
    }

}
