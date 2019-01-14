import Vapor
import FluentPostgreSQL

final class RoasterController {

    func createRoster(_ req: Request) throws -> Future<Roaster> {
        let customer = try req.requireAuthenticated(Customer.self)

        return try req.content.decode(CreateRoasterRequest.self)
            .flatMap(to: Roaster.self, { request in
                return Roaster(name: request.name, version: 1, gameId: request.gameId).save(on: req)
            })
            .flatMap(to: Roaster.self, { roaster in
                return roaster.users.attach(customer, on: req).then({ _ -> EventLoopFuture<Roaster> in
                    return req.future(roaster)
                })
            })
    }

    func getRoasters(_ req: Request) throws -> Future<[Roaster]> {
        let customer = try req.requireAuthenticated(Customer.self)
        return try customer.roasters.query(on: req).all()
    }

}
