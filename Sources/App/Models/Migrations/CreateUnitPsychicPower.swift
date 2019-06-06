import FluentPostgreSQL

struct CreateUnitPsychicPower: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UnitPsychicPower.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.psychicPowerId)
            builder.reference(from: \.unitId, to: \Unit.id, onDelete: .cascade)
            builder.reference(from: \.psychicPowerId, to: \PsychicPower.id, onDelete: .cascade)
            builder.unique(on: \.unitId, \.psychicPowerId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UnitPsychicPower.self, on: conn)
    }

}
