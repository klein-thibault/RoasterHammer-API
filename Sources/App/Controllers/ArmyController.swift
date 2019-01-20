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
        return try army.rules.query(on: conn).all()
            .map(to: ArmyResponse.self, { rules in
                return try ArmyResponse(army: army, rules: rules)
            })
    }

}
