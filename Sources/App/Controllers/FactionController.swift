import Vapor
import FluentPostgreSQL

final class FactionController {

    // MARK: - Public Functions

    func createFaction(_ req: Request) throws -> Future<Faction> {
        let armyId = try req.parameters.next(Int.self)
        return try req.content.decode(CreateFactionRequest.self)
            .flatMap(to: Faction.self, { request in
                return self.createFaction(armyId: armyId, request: request, conn: req)
            })
    }

    func getAllFactions(_ req: Request) -> Future<[Faction]> {
        return Faction.query(on: req).all()
    }

    func deleteFaction(_ req: Request) throws -> Future<HTTPStatus> {
        let factionId = try req.parameters.next(Int.self)
        return Faction.find(factionId, on: req)
            .unwrap(or: RoasterHammerError.factionIsMissing)
            .flatMap(to: HTTPStatus.self) { faction in
                return faction.delete(on: req)
                    .map(to: HTTPStatus.self, { _ in
                        return HTTPStatus.ok
                    })
        }
    }

    // MARK: - Utility Functions

    func factionResponse(faction: Faction, conn: DatabaseConnectable) throws -> Future<FactionResponse> {
        return try faction.rules.query(on: conn).all()
            .map(to: FactionResponse.self, { rules in
                return FactionResponse(faction: faction, rules: rules)
            })
    }

    // MARK: - Private Functions

    private func createFaction(armyId: Int, request: CreateFactionRequest, conn: DatabaseConnectable) -> Future<Faction> {
        return Faction(name: request.name, armyId: armyId).save(on: conn)
            .flatMap(to: Faction.self, { faction in
                return request.rules.map { Rule(name: $0.name, description: $0.description).save(on: conn) }
                    .flatten(on: conn)
                    .flatMap(to: [FactionRule].self, { rules in
                        return rules.map { faction.rules.attach($0, on: conn) }.flatten(on: conn)
                    })
                    .map(to: Faction.self, { _ in
                        return faction
                    })
            })
    }
}
