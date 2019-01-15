import Vapor
import FluentPostgreSQL

final class GameController {

    func createGame(_ req: Request) throws -> Future<Game> {
        let customer = try req.requireAuthenticated(Customer.self)

        return Game(name: "Warhammer 40,000", version: 8).save(on: req)
            .flatMap(to: Game.self, { game in
                return customer.games.attach(game, on: req).then({ _ in
                    return req.future(game)
                })
            })
    }

    func getGames(_ req: Request) throws -> Future<[Game]> {
        let customer = try req.requireAuthenticated(Customer.self)
        return try customer.games.query(on: req).all()
    }

}
