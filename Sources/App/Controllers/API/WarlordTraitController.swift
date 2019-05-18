import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class WarlordTraitController {

    // MARK: - Public Functions

    func createWarlordTrait(_ req: Request) throws -> Future<WarlordTraitResponse> {
        let armyId = try req.parameters.next(Int.self)

        return try req.content.decode(AddWarlordTraitRequest.self)
            .flatMap(to: WarlordTrait.self, { request in
                return WarlordTrait(name: request.name,
                                    description: request.description,
                                    armyId: armyId)
                    .save(on: req)
            })
            .map(to: WarlordTraitResponse.self, { warlordTrait in
                return try self.warlordTraitResponse(forWarlordTrait: warlordTrait)
            })
    }

    func deleteWarlordTrait(_ req: Request) throws -> Future<HTTPStatus> {
        let warlordTraitId = try req.parameters.next(Int.self)
        return deleteWarlordTraitById(warlordTraitId, conn: req)
    }

    // MARK: - Utilities Functions

    func warlordTraitResponse(forWarlordTrait warlordTrait: WarlordTrait) throws -> WarlordTraitResponse {
        let warlordTraitDTO = try WarlordTraitDTO(id: warlordTrait.requireID(),
                                                  name: warlordTrait.name,
                                                  description: warlordTrait.description)
        return WarlordTraitResponse(warlordTraitDTO: warlordTraitDTO)
    }

    func deleteWarlordTraitById(_ id: Int, conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return WarlordTrait
            .find(id, on: conn)
            .unwrap(or: RoasterHammerError.warlordTraitIsMissing.error())
            .delete(on: conn)
            .transform(to: .ok)
    }
    
}
