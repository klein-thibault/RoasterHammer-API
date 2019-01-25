import Vapor
import FluentPostgreSQL

final class UnitType: PostgreSQLModel {
    var id: Int?
    var name: String
    var units: Children<UnitType, Unit> {
        return children(\.unitTypeId)
    }

    init(name: String) {
        self.name = name
    }
}

extension UnitType: Content { }
extension UnitType: PostgreSQLMigration { }
