import FluentPostgreSQL

struct CreatePsychicPowerKeyword: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(PsychicPowerKeyword.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.psychicPowerId)
            builder.field(for: \.keywordId)
            builder.reference(from: \.psychicPowerId, to: \PsychicPower.id, onDelete: .cascade)
            builder.reference(from: \.keywordId, to: \Keyword.id, onDelete: .cascade)
            builder.unique(on: \.psychicPowerId, \.keywordId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(PsychicPowerKeyword.self, on: conn)
    }

}
