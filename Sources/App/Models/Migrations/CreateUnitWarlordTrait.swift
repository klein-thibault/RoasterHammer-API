import FluentPostgreSQL

struct CreateUnitWarlordTrait: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UnitWarlordTrait.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.warlordTraitId)
            builder.reference(from: \.unitId, to: \Unit.id, onDelete: .cascade)
            builder.reference(from: \.warlordTraitId, to: \WarlordTrait.id, onDelete: .cascade)
            builder.unique(on: \.unitId, \.warlordTraitId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UnitWarlordTrait.self, on: conn)
    }

}
