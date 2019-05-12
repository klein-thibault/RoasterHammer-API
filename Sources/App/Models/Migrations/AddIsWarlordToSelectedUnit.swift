import FluentPostgreSQL

struct AddIsWarlordToSelectedUnit: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(SelectedUnit.self, on: conn, closure: { (builder) in
            let defaultValueConstraint = PostgreSQLColumnConstraint.default(.literal("false"))
            builder.field(for: \.isWarlord, type: .boolean, defaultValueConstraint)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(SelectedUnit.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.isWarlord)
        })
    }
}
