import FluentPostgreSQL

struct CreateFactionRule: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(FactionRule.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.factionId)
            builder.field(for: \.ruleId)
            builder.reference(from: \.factionId, to: \Faction.id, onDelete: .cascade)
            builder.reference(from: \.ruleId, to: \Rule.id, onDelete: .cascade)
            builder.unique(on: \.factionId, \.ruleId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(FactionRule.self, on: conn)
    }

}
