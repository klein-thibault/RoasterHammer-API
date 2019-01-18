import Vapor
import FluentPostgreSQL

final class Role: PostgreSQLModel {
    var id: Int?
    var name: String
    var detachmentId: Int
    var detachments: Parent<Role, Detachment> {
        return parent(\.detachmentId)
    }
    var units: Siblings<Role, Unit, UnitRole> {
        return siblings()
    }

    init(name: String, detachmentId: Int) {
        self.name = name
        self.detachmentId = detachmentId
    }

}

extension Role: Content { }
extension Role: PostgreSQLMigration { }
