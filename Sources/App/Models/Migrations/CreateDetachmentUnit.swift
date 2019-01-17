import FluentPostgreSQL

struct CreateDetachmentUnit: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(DetachmentUnit.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitRoleId)
            builder.field(for: \.detachmentId)
            builder.reference(from: \.unitRoleId, to: \UnitRole.id, onDelete: .cascade)
            builder.reference(from: \.detachmentId, to: \Detachment.id, onDelete: .cascade)
            builder.unique(on: \.unitRoleId, \.detachmentId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(DetachmentUnit.self, on: conn)
    }

}
