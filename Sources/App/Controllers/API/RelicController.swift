import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class RelicController {

    // MARK: - Public Functions

    func createRelic(_ req: Request) throws -> Future<RelicResponse> {
        let armyId = try req.parameters.next(Int.self)

        return try req.content.decode(AddRelicRequest.self)
            .flatMap(to: Relic.self, { request in
                return Relic(name: request.name,
                             description: request.description,
                             armyId: armyId,
                             weaponId: request.weaponId)
                    .save(on: req)
            })
            .flatMap(to: RelicResponse.self, { relic in
                return try self.relicResponse(forRelic: relic, conn: req)
            })
    }

    // MARK: - Utilities Functions

    func relicResponse(forRelic relic: Relic, conn: DatabaseConnectable) throws -> Future<RelicResponse> {
        let armyFuture = relic.army.get(on: conn)
        let keywordsFuture = try relic.keywords.query(on: conn).all()
        let weaponFuture = Weapon.find(relic.weaponId ?? 0, on: conn)

        return flatMap(to: RelicResponse.self, armyFuture, keywordsFuture, weaponFuture, { (army, keywords, weapon) in
            let armyResponseFuture = try ArmyController().armyResponse(forArmy: army, conn: conn)
            var weaponResponse: WeaponResponse? = nil

            if let weapon = weapon {
                weaponResponse = try WeaponController().weaponResponse(forWeapon: weapon)
            }

            let relicDTO = try RelicDTO(id: relic.requireID(), name: relic.name, description: relic.description)
            let keywordNames = keywords.map { $0.name }

            return armyResponseFuture.map(to: RelicResponse.self, { (armyResponse) in
                return RelicResponse(relicDTO: relicDTO, army: armyResponse, weapon: weaponResponse, keywords: keywordNames)
            })
        })
    }

}
