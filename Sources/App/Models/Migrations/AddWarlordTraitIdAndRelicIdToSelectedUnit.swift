import FluentPostgreSQL

struct AddWarlordTraitIdAndRelicIdToSelectedUnit: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(SelectedUnit.self, on: conn, closure: { (builder) in
            builder.field(for: \.warlordTraitId)
            builder.field(for: \.relicId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(SelectedUnit.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.warlordTraitId)
            builder.deleteField(for: \.relicId)
        })
    }
}
