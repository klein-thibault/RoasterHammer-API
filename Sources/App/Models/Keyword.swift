import Vapor
import FluentPostgreSQL

final class Keyword: PostgreSQLModel {
    var id: Int?
    var name: String
    var units: Siblings<Keyword, Unit, UnitKeyword> {
        return siblings()
    }

    init(name: String) {
        self.name = name
    }
}

extension Keyword: Content { }
extension Keyword: PostgreSQLMigration { }
