import Vapor
import FluentPostgreSQL

final class ArmyController {

    // MARK: - Public Functions

    func createArmy(_ req: Request) throws -> Future<Army> {
        return try req.content.decode(Army.self)
            .flatMap(to: Army.self, { army in
                return army.save(on: req)
            })
    }

    func armies(_ req: Request) throws -> Future<[Army]> {
        return Army.query(on: req).all()
    }

    // MARK: - Utility Functions

    func armyResponse(forArmy army: Army,
                      conn: DatabaseConnectable) throws -> Future<ArmyResponse> {
        let factionsFuture = try army.factions.query(on: conn).all()
        let rulesFuture = try army.rules.query(on: conn).all()

        return flatMap(to: ArmyResponse.self, factionsFuture, rulesFuture, { (factions, rules) in
            let factionController = FactionController()
            return try factions.map { try factionController.factionResponse(faction: $0, conn: conn) }
                .flatten(on: conn)
                .map(to: ArmyResponse.self, { factions in
                    return try ArmyResponse(army: army, factions: factions, rules: rules)
                })
        })
    }

}
