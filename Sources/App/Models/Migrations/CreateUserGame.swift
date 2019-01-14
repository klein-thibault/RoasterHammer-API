import FluentPostgreSQL

struct CreateUserGame: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UserGame.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.gameId)
            builder.field(for: \.userId)
            builder.reference(from: \.gameId, to: \Game.id, onDelete: .cascade)
            builder.reference(from: \.userId, to: \Customer.id, onDelete: .cascade)
            builder.unique(on: \.gameId, \.userId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UserGame.self, on: conn)
    }

}
