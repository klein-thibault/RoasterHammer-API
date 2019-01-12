import FluentPostgreSQL

struct CreateGameRule: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(GameRule.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.gameId)
            builder.field(for: \.ruleId)
            builder.reference(from: \.gameId, to: \Game.id, onDelete: .cascade)
            builder.reference(from: \.ruleId, to: \Rule.id, onDelete: .cascade)
            builder.unique(on: \.gameId, \.ruleId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(GameRule.self, on: conn)
    }

}
