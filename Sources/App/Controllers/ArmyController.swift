import Vapor
import FluentPostgreSQL

final class ArmyController {

    func createArmy(_ req: Request) throws -> Future<Army> {
        return try req.content.decode(Army.self).flatMap(to: Army.self, { army in
            return army.save(on: req)
        })
    }

    func armies(_ req: Request) throws -> Future<[Army]> {
        return Army.query(on: req).all()
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
