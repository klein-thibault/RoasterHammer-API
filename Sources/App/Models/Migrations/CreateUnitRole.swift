import FluentPostgreSQL

struct CreateUnitRole: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UnitRole.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.roleId)
            builder.reference(from: \.unitId, to: \SelectedUnit.id, onDelete: .cascade)
            builder.reference(from: \.roleId, to: \Role.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UnitRole.self, on: conn)
    }

}
