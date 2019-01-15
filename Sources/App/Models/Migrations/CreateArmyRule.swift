import FluentPostgreSQL

struct CreateArmyRule: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(ArmyRule.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.armyId)
            builder.field(for: \.ruleId)
            builder.reference(from: \.armyId, to: \Army.id, onDelete: .cascade)
            builder.reference(from: \.ruleId, to: \Rule.id, onDelete: .cascade)
            builder.unique(on: \.armyId, \.ruleId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(ArmyRule.self, on: conn)
    }

}
