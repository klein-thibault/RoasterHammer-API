import Vapor
import FluentPostgreSQL

final class UnitRole: PostgreSQLModel {
    var id: Int?
    var name: String
    var detachmentId: Int
    var detachments: Parent<UnitRole, Detachment> {
        return parent(\.detachmentId)
    }

    init(name: String, detachmentId: Int) {
        self.name = name
        self.detachmentId = detachmentId
    }

}

extension UnitRole: Content { }
extension UnitRole: PostgreSQLMigration { }
