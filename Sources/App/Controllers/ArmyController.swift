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

}
