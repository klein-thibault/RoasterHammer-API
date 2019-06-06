import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class PsychicPowerController {

    // MARK: - Public Functions

    func createPsychicPower(_ req: Request) throws -> Future<ArmyResponse> {
        let armyId = try req.parameters.next(Int.self)

        return try req.content.decode(CreatePsychicPowerRequest.self)
            .flatMap(to: PsychicPower.self, { request in
                self.createPsychicPower(request: request, armyId: armyId, conn: req)
            })
            .flatMap(to: ArmyResponse.self, { relic in
                return try ArmyController().getArmy(byID: armyId, conn: req)
            })
    }

    func deletePsychicPower(_ req: Request) throws -> Future<HTTPStatus> {
        let psychicPowerId = try req.parameters.next(Int.self)

        return deletePsychicPowerById(psychicPowerId, conn: req)
    }

    // MARK: - Utilities Functions

    func psychicPowerResponse(forPsychicPower psychicPower: PsychicPower,
                              conn: DatabaseConnectable) throws -> Future<PsychicPowerResponse> {
        return try psychicPower.keywords.query(on: conn).all()
            .map(to: PsychicPowerResponse.self, { keywords in
                let psychicPowerDTO = try PsychicPowerDTO(id: psychicPower.requireID(),
                                                          name: psychicPower.name,
                                                          description: psychicPower.description)
                let keywordNames = keywords.map { $0.name }

                return PsychicPowerResponse(psychicPowerDTO: psychicPowerDTO, keywords: keywordNames)
            })
    }

    func psychicPowerResponseOptional(forPsychicPower psychicPower: PsychicPower?,
                              conn: DatabaseConnectable) throws -> Future<PsychicPowerResponse?> {
        guard let psychicPower = psychicPower else {
            return conn.future(nil)
        }

        return try psychicPowerResponse(forPsychicPower: psychicPower, conn: conn)
            .map(to: PsychicPowerResponse?.self, { psychicPowerResponse in
                return psychicPowerResponse
            })
    }

    func createPsychicPower(request: CreatePsychicPowerRequest, armyId: Int, conn: DatabaseConnectable) -> Future<PsychicPower> {
        return PsychicPower(name: request.name,
                            description: request.description,
                            armyId: armyId)
        .save(on: conn)
            .flatMap(to: PsychicPower.self, { psychicPower in
                return KeywordController().getKeywordsForIds(request.keywordIds, conn: conn)
                    .flatMap(to: [PsychicPowerKeyword].self, { keywords in
                        return keywords.map { psychicPower.keywords.attach($0, on: conn) }
                            .flatten(on: conn)
                    })
                    .map(to: PsychicPower.self, { _ in
                        return psychicPower
                    })
            })
    }

    func deletePsychicPowerById(_ id: Int, conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return PsychicPower
            .find(id, on: conn)
            .unwrap(or: RoasterHammerError.psychicPowerIsMissing.error())
            .delete(on: conn)
            .transform(to: .ok)
    }
}
