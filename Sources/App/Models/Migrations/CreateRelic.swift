import FluentPostgreSQL

struct CreateRelic: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(Relic.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.description)
            builder.field(for: \.armyId)
            builder.reference(from: \.armyId, to: \Army.id, onDelete: .cascade)
            builder.field(for: \.weaponId)
            builder.reference(from: \.weaponId, to: \Weapon.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(Relic.self, on: conn)
    }
}
