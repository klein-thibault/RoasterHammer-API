import Vapor
import FluentPostgreSQL

final class RoasterController {

    func createRoster(_ req: Request) throws -> Future<Roaster> {
        _ = try req.requireAuthenticated(Customer.self)

        return try req.content.decode(CreateRoasterRequest.self)
            .flatMap(to: Roaster.self, { request in
                return Roaster(name: request.name, version: 1, gameId: request.gameId).save(on: req)
            })
    }

    func getRoasters(_ req: Request) throws -> Future<[Roaster]> {
        let customer = try req.requireAuthenticated(Customer.self)
        return try customer.games.query(on: req).all().flatMap(to: [Roaster].self, { games in
            var getRoastersFutures: [Future<[Roaster]>] = []

            for game in games {
                let getRoastersFuture = try game.roasters.query(on: req).all()
                getRoastersFutures.append(getRoastersFuture)
            }

            return getRoastersFutures.flatten(on: req).then({ (listOfRoasters) -> EventLoopFuture<[Roaster]> in
                let flattenRoasters = listOfRoasters.flatMap { $0 }
                return req.future(flattenRoasters)
            })
        })
    }

}
