import Vapor
import FluentPostgreSQL

final class UnitRoleController {

    func createUnitRole(_ req: Request) throws -> Future<UnitRole> {
        return try req.content.decode(CreateUnitRoleRequest.self).flatMap(to: UnitRole.self, { request in
            return UnitRole(name: request.name).save(on: req)
        })
    }

}
