import FluentPostgreSQL

struct CreateUserRoaster: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UserRoaster.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.roasterId)
            builder.field(for: \.userId)
            builder.reference(from: \.roasterId, to: \Roaster.id, onDelete: .cascade)
            builder.reference(from: \.userId, to: \Customer.id, onDelete: .cascade)
            builder.unique(on: \.roasterId, \.userId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UserRoaster.self, on: conn)
    }

}
