import Vapor
import FluentPostgreSQL

final class ArmyController {

    // MARK: - Public Functions

    func createArmy(_ req: Request) throws -> Future<Army> {
        return try req.content.decode(CreateArmyRequest.self)
            .flatMap(to: Army.self, { request in
                return self.createArmy(request: request, conn: req)
            })
    }

    func getArmy(_ req: Request) throws -> Future<ArmyResponse> {
        let armyId = try req.parameters.next(Int.self)
        return try getArmy(byID: armyId, conn: req)
    }

    func armies(_ req: Request) throws -> Future<[ArmyResponse]> {
        return Army.query(on: req).all()
            .flatMap(to: [ArmyResponse].self, { armies in
                return try armies
                    .map { try self.armyResponse(forArmy: $0, conn: req) }
                    .flatten(on: req)
            })
    }

    // MARK: - Utility Functions

    func getArmy(byID id: Int, conn: DatabaseConnectable) throws -> Future<ArmyResponse> {
        return Army.find(id, on: conn)
            .unwrap(or: RoasterHammerError.armyIsMissing.error())
            .flatMap(to: ArmyResponse.self, { army in
                return try self.armyResponse(forArmy: army, conn: conn)
            })
    }

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

    func createArmy(request: CreateArmyRequest, conn: DatabaseConnectable) -> Future<Army> {
        return Army(name: request.name)
            .save(on: conn)
            .flatMap(to: Army.self, { army in
                return self.createRules(forArmy: army, rules: request.rules, conn: conn)
            })
    }

    // MARK: - Private Functions

    private func createRules(forArmy army: Army,
                             rules: [AddRuleRequest],
                             conn: DatabaseConnectable) -> Future<Army> {
        let rulesFuture = rules
            .map { Rule(name: $0.name, description: $0.description).save(on: conn) }
            .flatten(on: conn)
        return rulesFuture
            .flatMap(to: [ArmyRule].self, { rules in
                return rules.map { army.rules.attach($0, on: conn) }.flatten(on: conn)
            })
            .map(to: Army.self, { _ in
                return army
            })
    }

}
