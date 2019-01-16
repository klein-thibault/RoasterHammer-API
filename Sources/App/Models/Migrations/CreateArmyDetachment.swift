import FluentPostgreSQL

struct CreateArmyDetachment: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(ArmyDetachment.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.armyId)
            builder.field(for: \.detachmentId)
            builder.reference(from: \.armyId, to: \Army.id, onDelete: .cascade)
            builder.reference(from: \.detachmentId, to: \Detachment.id, onDelete: .cascade)
            builder.unique(on: \.armyId, \.detachmentId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(ArmyDetachment.self, on: conn)
    }

}
