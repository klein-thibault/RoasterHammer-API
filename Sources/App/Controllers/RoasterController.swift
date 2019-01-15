import Vapor
import FluentPostgreSQL

final class RoasterController {

    func createRoster(_ req: Request) throws -> Future<Roaster> {
        _ = try req.requireAuthenticated(Customer.self)
        let gameId = try req.parameters.next(Int.self)

        return try req.content.decode(CreateRoasterRequest.self)
            .flatMap(to: Roaster.self, { request in
                return Roaster(name: request.name, version: 1, gameId: gameId).save(on: req)
            })
    }

    func getRoasters(_ req: Request) throws -> Future<[Roaster]> {
        let customer = try req.requireAuthenticated(Customer.self)
        let gameId = try req.parameters.next(Int.self)

        return try customer.games
            .query(on: req)
            .filter(\.id == gameId)
            .first()
            .unwrap(or: RoasterHammerError.gameIsMissing)
            .flatMap(to: [Roaster].self, { game in
                return try game.roasters.query(on: req).all()
        })
    }

    func addArmyToRoaster(_ req: Request) throws -> Future<Roaster> {
        _ = try req.requireAuthenticated(Customer.self)
        _ = try req.parameters.next(Int.self)
        let roasterId = try req.parameters.next(Int.self)

        return try req.content.decode(AddArmyToRoasterRequest.self)
            .flatMap(to: Army.self, { request in
                return Army.find(request.armyId, on: req).unwrap(or: RoasterHammerError.armyIsMissing)
            })
            .flatMap(to: Roaster.self, { army in
                return Roaster.find(roasterId, on: req).unwrap(or: RoasterHammerError.roasterIsMissing)
                    .then({ roaster in
                        return roaster.armies.attach(army, on: req).then({ _ in
                            return req.future(roaster)
                        })
                })
            })
    }

}
