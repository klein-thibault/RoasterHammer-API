import FluentPostgreSQL

struct CreateRelicKeyword: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(RelicKeyword.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.relicId)
            builder.field(for: \.keywordId)
            builder.reference(from: \.relicId, to: \Relic.id, onDelete: .cascade)
            builder.reference(from: \.keywordId, to: \Keyword.id, onDelete: .cascade)
            builder.unique(on: \.relicId, \.keywordId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(RelicKeyword.self, on: conn)
    }

}
