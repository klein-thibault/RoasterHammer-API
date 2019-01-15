import FluentPostgreSQL

struct CreateRoasterArmy: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(RoasterArmy.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.armyId)
            builder.field(for: \.roasterId)
            builder.reference(from: \.armyId, to: \Army.id, onDelete: .cascade)
            builder.reference(from: \.roasterId, to: \Roaster.id, onDelete: .cascade)
            builder.unique(on: \.armyId, \.roasterId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(RoasterArmy.self, on: conn)
    }

}
