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

    func editFaction(_ req: Request) throws -> Future<FactionResponse> {
        let factionId = try req.parameters.next(Int.self)
        return try req.content.decode(EditFactionRequest.self)
            .flatMap(to: Faction.self, { request in
                return self.editFaction(factionId: factionId, request: request, conn: req)
            })
            .flatMap(to: FactionResponse.self, { faction in
                return try self.factionResponse(faction: faction, conn: req)
            })
    }

    func deleteFaction(_ req: Request) throws -> Future<HTTPStatus> {
        let factionId = try req.parameters.next(Int.self)
        return deleteFaction(factionId: factionId, conn: req)
    }

    // MARK: - Utility Functions

    func factionResponse(faction: Faction, conn: DatabaseConnectable) throws -> Future<FactionResponse> {
        return try faction.rules.query(on: conn).all()
            .map(to: FactionResponse.self, { rules in
                return try FactionResponse(faction: faction, rules: rules)
            })
    }

    func createFaction(armyId: Int, request: CreateFactionRequest, conn: DatabaseConnectable) -> Future<Faction> {
        return Faction(name: request.name, armyId: armyId).save(on: conn)
            .flatMap(to: Faction.self, { faction in
                return self.createRules(forFaction: faction, rules: request.rules, conn: conn)
            })
    }

    func getFaction(byID id: Int, conn: DatabaseConnectable) throws -> Future<FactionResponse> {
        return Faction.find(id, on: conn)
            .unwrap(or: RoasterHammerError.factionIsMissing)
            .flatMap(to: FactionResponse.self, { faction in
                return try self.factionResponse(faction: faction, conn: conn)
            })
    }

    func editFaction(factionId: Int, request: EditFactionRequest, conn: DatabaseConnectable) -> Future<Faction> {
        return Faction.find(factionId, on: conn)
        .unwrap(or: RoasterHammerError.factionIsMissing)
            .flatMap(to: Faction.self, { faction in
                guard let name = request.name else {
                    return conn.eventLoop.future(faction)
                }
                faction.name = name
                return faction.save(on: conn)
            })
            .flatMap(to: Faction.self, { faction in
                guard let armyId = request.armyId else {
                    return conn.eventLoop.future(faction)
                }
                faction.armyId = armyId
                return faction.save(on: conn)
            })
            .flatMap(to: Faction.self, { faction in
                guard let rules = request.rules else {
                    return conn.eventLoop.future(faction)
                }
                return self.editRules(forFaction: faction,
                                      updatedRules: rules,
                                      conn: conn)
            })
    }

    func deleteFaction(factionId: Int, conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return Faction.find(factionId, on: conn)
            .unwrap(or: RoasterHammerError.factionIsMissing.error())
            .flatMap(to: HTTPStatus.self) { faction in
                return faction.delete(on: conn)
                    .transform(to: HTTPStatus.ok)
        }
    }

    // MARK: - Private Functions

    private func createRules(forFaction faction: Faction,
                             rules: [AddRuleRequest],
                             conn: DatabaseConnectable) -> Future<Faction> {
        return rules.map { Rule(name: $0.name, description: $0.description).save(on: conn) }
            .flatten(on: conn)
            .flatMap(to: [FactionRule].self, { rules in
                return rules.map { faction.rules.attach($0, on: conn) }.flatten(on: conn)
            })
            .map(to: Faction.self, { _ in
                return faction
            })
    }

    private func editRules(forFaction faction: Faction,
                           updatedRules: [AddRuleRequest],
                           conn: DatabaseConnectable) -> Future<Faction> {
        return faction.rules.detachAll(on: conn)
            .flatMap(to: Faction.self, { _ in
                return self.createRules(forFaction: faction,
                                        rules: updatedRules,
                                        conn: conn)
            })
    }
}
