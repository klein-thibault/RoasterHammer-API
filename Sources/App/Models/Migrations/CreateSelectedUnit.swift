import FluentPostgreSQL

struct CreateSelectedUnit: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(SelectedUnit.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.reference(from: \.unitId, to: \Unit.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(SelectedUnit.self, on: conn)
    }

}
