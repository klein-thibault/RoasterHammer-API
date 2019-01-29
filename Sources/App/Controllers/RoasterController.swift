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
            .unwrap(or: RoasterHammerError.gameIsMissing.error())
            .flatMap(to: [Roaster].self, { game in
                return try game.roasters.query(on: req).all()
            }).flatMap(to: [RoasterResponse].self, { roasters in
                let roasterResponseFutures = try roasters.map { try self.roasterResponse(forRoaster: $0, conn: req) }
                return roasterResponseFutures.flatten(on: req)
            })
    }

    func getRoasterById(_ req: Request) throws -> Future<RoasterResponse> {
        let roasterId = try req.parameters.next(Int.self)

        return Roaster.find(roasterId, on: req).unwrap(or: RoasterHammerError.roasterIsMissing.error())
            .flatMap(to: RoasterResponse.self, { roaster in
                return try self.roasterResponse(forRoaster: roaster, conn: req)
            })
    }

    // MARK: - Utility Functions

    func roasterResponse(forRoaster roaster: Roaster,
                                 conn: DatabaseConnectable) throws -> Future<RoasterResponse> {
        let detachmentsFuture = try roaster.detachments.query(on: conn).all()
        let rulesFuture = try roaster.rules.query(on: conn).all()

        return flatMap(to: RoasterResponse.self, detachmentsFuture, rulesFuture, { (detachments, rules) in
            let detachmentController = DetachmentController()
            let detachmentResponses = try detachments
                .map { try detachmentController.detachmentResponse(forDetachment: $0, conn: conn) }
                .flatten(on: conn)

            return detachmentResponses.map(to: RoasterResponse.self, { detachments in
                return try RoasterResponse(roaster: roaster, detachments: detachments, rules: rules)
            })
        })
    }

}
