import FluentPostgreSQL

struct CreateRoasterRule: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(RoasterRule.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.roasterId)
            builder.field(for: \.ruleId)
            builder.reference(from: \.roasterId, to: \Roaster.id, onDelete: .cascade)
            builder.reference(from: \.ruleId, to: \Rule.id, onDelete: .cascade)
            builder.unique(on: \.roasterId, \.ruleId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(RoasterRule.self, on: conn)
    }

}
