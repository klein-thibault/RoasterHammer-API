import FluentPostgreSQL

struct CreateRoasterDetachment: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(RoasterDetachment.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.roasterId)
            builder.field(for: \.detachmentId)
            builder.reference(from: \.roasterId, to: \Roaster.id, onDelete: .cascade)
            builder.reference(from: \.detachmentId, to: \Detachment.id, onDelete: .cascade)
            builder.unique(on: \.roasterId, \.detachmentId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(RoasterDetachment.self, on: conn)
    }

}
