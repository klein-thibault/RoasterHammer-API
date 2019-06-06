import FluentPostgreSQL

struct AddPsychicPowerToSelectedUnit: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(SelectedUnit.self, on: conn, closure: { (builder) in
            builder.field(for: \.psychicPowerId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(SelectedUnit.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.psychicPowerId)
        })
    }
}
