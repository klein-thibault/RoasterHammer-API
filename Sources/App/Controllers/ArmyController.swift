import Vapor
import FluentPostgreSQL

final class ArmyController {

    // MARK: - Public Functions

    func createArmy(_ req: Request) throws -> Future<Army> {
        return try req.content.decode(Army.self)
            .flatMap(to: Army.self, { army in
                return army.save(on: req)
            })
    }

    func armies(_ req: Request) throws -> Future<[Army]> {
        return Army.query(on: req).all()
    }

    func addArmyToRoaster(_ req: Request) throws -> Future<RoasterResponse> {
        _ = try req.requireAuthenticated(Customer.self)
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
            .flatMap(to: RoasterResponse.self, { roaster in
                let roasterController = RoasterController()
                return try roasterController.roasterResponse(forRoaster: roaster, conn: req)
            })
    }

    // MARK: - Utility Functions

    func armyResponse(forArmy army: Army,
                      conn: DatabaseConnectable) throws -> Future<ArmyResponse> {
        let detachmentsFuture = try army.detachments.query(on: conn).all()
        let rulesFuture = try army.rules.query(on: conn).all()

        return flatMap(to: ArmyResponse.self, detachmentsFuture, rulesFuture, { (detachments, rules) in
            let detachmentController = DetachmentController()
            return try detachments.map { try detachmentController.detachmentResponse(forDetachment: $0, conn: conn) }
                .flatten(on: conn)
                .map(to: ArmyResponse.self, { detachments in
                    return try ArmyResponse(army: army, detachments: detachments, rules: rules)
                })
        })
    }

}
