import FluentPostgreSQL

struct CreateSelectedUnitPsychicPower: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(SelectedUnitPsychicPower.self, on: conn) { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.psychicPowerId)
            builder.reference(from: \.unitId, to: \SelectedUnit.id, onDelete: .cascade)
            builder.reference(from: \.psychicPowerId, to: \PsychicPower.id, onDelete: .cascade)
            builder.unique(on: \.unitId, \.psychicPowerId)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(SelectedUnitPsychicPower.self, on: conn)
    }

}
