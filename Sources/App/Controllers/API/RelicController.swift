import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class RelicController {

    // MARK: - Public Functions

    func createRelic(_ req: Request) throws -> Future<ArmyResponse> {
        let armyId = try req.parameters.next(Int.self)

        return try req.content.decode(AddRelicRequest.self)
            .flatMap(to: Relic.self, { request in
                return Relic(name: request.name,
                             description: request.description,
                             armyId: armyId,
                             weaponId: request.weaponId)
                    .save(on: req)
            })
            .flatMap(to: ArmyResponse.self, { relic in
                return try ArmyController().getArmy(byID: armyId, conn: req)
            })
    }

    func deleteRelic(_ req: Request) throws -> Future<HTTPStatus> {
        let relicId = try req.parameters.next(Int.self)

        return getRelicByID(relicId, conn: req)
            .flatMap({ relic in
                return relic.delete(on: req)
            })
            .transform(to: HTTPStatus.ok)
    }

    // MARK: - Utils Functions

    func relicResponse(forRelic relic: Relic, conn: DatabaseConnectable) throws -> Future<RelicResponse> {
        let keywordsFuture = try relic.keywords.query(on: conn).all()
        let weaponFuture = Weapon.find(relic.weaponId ?? 0, on: conn)

        return map(to: RelicResponse.self, keywordsFuture, weaponFuture, { (keywords, weapon) in
            var weaponResponse: WeaponResponse? = nil

            if let weapon = weapon {
                weaponResponse = try WeaponController().weaponResponse(forWeapon: weapon)
            }

            let relicDTO = try RelicDTO(id: relic.requireID(), name: relic.name, description: relic.description)
            let keywordNames = keywords.map { $0.name }

            return RelicResponse(relicDTO: relicDTO, weapon: weaponResponse, keywords: keywordNames)
        })
    }

    // MARK: - Private Functions

    private func getRelicByID(_ id: Int, conn: DatabaseConnectable) -> Future<Relic> {
        return Relic
            .find(id, on: conn)
            .unwrap(or: RoasterHammerError.relicIsMissing.error())
    }

}
