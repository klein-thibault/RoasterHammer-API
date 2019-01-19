import Vapor
import FluentPostgreSQL

final class RoasterController {

    // MARK: - Public Functions

    func createRoster(_ req: Request) throws -> Future<RoasterResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let gameId = try req.parameters.next(Int.self)

        return try req.content.decode(CreateRoasterRequest.self)
            .flatMap(to: Roaster.self, { request in
                return Roaster(name: request.name, version: 1, gameId: gameId).save(on: req)
            })
            .flatMap(to: RoasterResponse.self, { roaster in
                return try self.roasterResponse(forRoaster: roaster, conn: req)
            })
    }

    func getRoasters(_ req: Request) throws -> Future<[RoasterResponse]> {
        let customer = try req.requireAuthenticated(Customer.self)
        let gameId = try req.parameters.next(Int.self)

        return try customer.games
            .query(on: req)
            .filter(\Game.id == gameId)
            .first()
            .unwrap(or: RoasterHammerError.gameIsMissing)
            .flatMap(to: [Roaster].self, { game in
                return try game.roasters.query(on: req).all()
            }).flatMap(to: [RoasterResponse].self, { roasters in
                let roasterResponseFutures = try roasters.map { try self.roasterResponse(forRoaster: $0, conn: req) }
                return roasterResponseFutures.flatten(on: req)
            })
    }

    // MARK: - Utility Functions

    func roasterResponse(forRoaster roaster: Roaster,
                                 conn: DatabaseConnectable) throws -> Future<RoasterResponse> {
        let armiesFuture = try roaster.armies.query(on: conn).all()
        let rulesFuture = try roaster.rules.query(on: conn).all()

        return flatMap(to: RoasterResponse.self, armiesFuture, rulesFuture, { (armies, rules) in
            let armyController = ArmyController()
            let armyResponses = try armies
                .map { try armyController.armyResponse(forArmy: $0, conn: conn) }
                .flatten(on: conn)

            return armyResponses.map(to: RoasterResponse.self, { armies in
                return try RoasterResponse(roaster: roaster, armies: armies, rules: rules)
            })
        })
    }

}
