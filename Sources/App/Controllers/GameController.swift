import Vapor
import FluentPostgreSQL

final class GameController {

    func createGame(_ req: Request) throws -> Future<GameResponse> {
        let customer = try req.requireAuthenticated(Customer.self)

        return Game(name: "Warhammer 40,000", version: 8).save(on: req)
            .flatMap(to: Game.self, { game in
                return customer.games.attach(game, on: req).then({ _ in
                    return req.future(game)
                })
            })
            .flatMap(to: GameResponse.self, { game in
                let response = try GameResponse(game: game, roasters: [])
                return req.future(response)
            })
    }

    func games(_ req: Request) throws -> Future<[GameResponse]> {
        let customer = try req.requireAuthenticated(Customer.self)
        return try customer.games
            .query(on: req)
            .all()
            .flatMap(to: [GameResponse].self, { games in
                let gameResponseFutures = try games.map({ game in
                    try game.roasters.query(on: req).all().map({ roasters in
                        return try GameResponse(game: game, roasters: roasters)
                    })
                })

                return gameResponseFutures.flatten(on: req)
            })
    }

    func gameById(_ req: Request) throws -> Future<GameResponse> {
        let customer = try req.requireAuthenticated(Customer.self)
        let gameId = try req.parameters.next(Int.self)
        return try customer.games
            .query(on: req)
            .filter(\.id == gameId)
            .first()
            .unwrap(or: RoasterHammerError.gameIsMissing)
            .flatMap(to: GameResponse.self, { game in
                return try game.roasters.query(on: req).all()
                    .flatMap(to: GameResponse.self, { roasters in
                        let response = try GameResponse(game: game, roasters: roasters)
                        return req.future(response)
                    })
            })
    }

}
