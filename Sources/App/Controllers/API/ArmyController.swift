import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

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
        return try getAllArmies(conn: req)
    }

    func editArmy(_ req: Request) throws -> Future<ArmyResponse> {
        let armyId = try req.parameters.next(Int.self)
        return try req.content.decode(EditArmyRequest.self)
            .flatMap(to: Army.self, { request in
                return self.editArmy(armyId: armyId, request: request, conn: req)
            })
            .flatMap(to: ArmyResponse.self, { army in
                return try self.armyResponse(forArmy: army, conn: req)
            })
    }

    func deleteArmy(_ req: Request) throws -> Future<HTTPStatus> {
        let armyId = try req.parameters.next(Int.self)
        return deleteArmy(armyId: armyId, conn: req)
    }

    func getAllFactionsForArmy(_ req: Request) throws -> Future<[FactionResponse]> {
        let armyId = try req.parameters.next(Int.self)

        return Army.find(armyId, on: req)
            .unwrap(or: RoasterHammerError.armyIsMissing.error())
            .flatMap(to: [Faction].self, { army in
                return try army.factions.query(on: req).all()
            })
            .flatMap(to: [FactionResponse].self, { factions in
                let factionController = FactionController()

                return try factions
                    .map { try factionController.factionResponse(faction: $0, conn: req) }
                    .flatten(on: req)
            })
    }

    // MARK: - Utility Functions

    func getAllArmies(conn: DatabaseConnectable) throws -> Future<[ArmyResponse]> {
        return Army.query(on: conn).all()
            .flatMap(to: [ArmyResponse].self, { armies in
                return try armies
                    .map { try self.armyResponse(forArmy: $0, conn: conn) }
                    .flatten(on: conn)
            })
    }

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
                    let armyDTO = ArmyDTO(id: try army.requireID(), name: army.name)
                    let rulesResponse = RuleController().rulesResponse(forRules: rules)
                    return ArmyResponse(army: armyDTO, factions: factions, rules: rulesResponse)
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

    func editArmy(armyId: Int, request: EditArmyRequest, conn: DatabaseConnectable) -> Future<Army> {
        return Army.find(armyId, on: conn)
            .unwrap(or: RoasterHammerError.armyIsMissing.error())
            .flatMap(to: Army.self, { army in
                guard let name = request.name else {
                    return conn.eventLoop.future(army)
                }
                army.name = name
                return army.save(on: conn)
            })
            .flatMap(to: Army.self, { army in
                guard let rules = request.rules else {
                    return conn.eventLoop.future(army)
                }
                return self.editRules(forArmy: army,
                                      updatedRules: rules,
                                      conn: conn)
            })
    }

    func deleteArmy(armyId: Int, conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return Army.find(armyId, on: conn)
            .unwrap(or: RoasterHammerError.armyIsMissing)
            .delete(on: conn)
            .transform(to: HTTPStatus.ok)
    }

    func assignRule(_ rule: Rule, toArmy army: Army, conn: DatabaseConnectable) -> Future<ArmyRule> {
        return army.rules.attach(rule, on: conn)
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

    private func editRules(forArmy army: Army,
                           updatedRules: [AddRuleRequest],
                           conn: DatabaseConnectable) -> Future<Army> {
        return army.rules.detachAll(on: conn)
            .flatMap(to: Army.self, { _ in
                return self.createRules(forArmy: army, rules: updatedRules, conn: conn)
            })
    }

}
