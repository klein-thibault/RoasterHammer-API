import FluentPostgreSQL

struct AddMinMaxPsychicPowerQuantityToUnit: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Unit.self, on: conn) { (builder) in
            builder.field(for: \.minPsychicPowerQuantity)
            builder.field(for: \.maxPsychicPowerQuantity)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Unit.self, on: conn) { (builder) in
            builder.deleteField(for: \.minPsychicPowerQuantity)
            builder.deleteField(for: \.maxPsychicPowerQuantity)
        }
    }
}
