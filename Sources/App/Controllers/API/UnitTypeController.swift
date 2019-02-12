import Vapor
import FluentPostgreSQL

final class UnitTypeController {

    // MARK: - Public Functions

    func getAllUnitTypes(_ req: Request) -> Future<[UnitType]> {
        return getAllUnitTypes(conn: req)
    }

    // MARK: - Utilities Functions

    func getAllUnitTypes(conn: DatabaseConnectable) -> Future<[UnitType]> {
        return UnitType.query(on: conn).all()
    }

}
