import Vapor
import FluentPostgreSQL

final class RoasterController {

    func createRoster(_ req: Request) throws -> Future<Roaster> {
        _ = try req.requireAuthenticated(Customer.self)
        let gameIdParameter: String = try req.parameters.next()
        guard let gameId = Int(gameIdParameter) else {
            throw Abort(.badRequest, reason: "The Game identifier format is invalid")
        }

        return try req.content.decode(CreateRoasterRequest.self)
            .flatMap(to: Roaster.self, { request in
                return Roaster(name: request.name, version: 1, gameId: gameId).save(on: req)
            })
    }

    func getRoasters(_ req: Request) throws -> Future<[Roaster]> {
        let customer = try req.requireAuthenticated(Customer.self)
        let gameIdParameter: String = try req.parameters.next()
        guard let gameId = Int(gameIdParameter) else {
            throw Abort(.badRequest, reason: "The Game identifier format is invalid")
        }

        return try customer.games
            .query(on: req)
            .filter(\.id == gameId)
            .first()
            .unwrap(or: RoasterHammerError.gameIsMissing)
            .flatMap(to: [Roaster].self, { game in
                return try game.roasters.query(on: req).all()
        })
    }

}
