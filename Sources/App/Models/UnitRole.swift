import Vapor
import FluentPostgreSQL

final class UnitRole: PostgreSQLModel {
    var id: Int?
    var name: String
    var detachments: Siblings<UnitRole, Detachment, DetachmentUnit> {
        return siblings()
    }

    init(name: String) {
        self.name = name
    }

}

extension UnitRole: Content { }
extension UnitRole: PostgreSQLMigration { }
