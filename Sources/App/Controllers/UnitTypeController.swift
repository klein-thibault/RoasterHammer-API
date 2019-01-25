import Vapor
import FluentPostgreSQL

final class UnitTypeController {

    func getAllUnitTypes(_ req: Request) -> Future<[UnitType]> {
        return UnitType.query(on: req).all()
    }

}
