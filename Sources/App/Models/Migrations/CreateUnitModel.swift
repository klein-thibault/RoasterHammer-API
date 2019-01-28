import FluentPostgreSQL

struct CreateUnitModel: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UnitModel.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.modelId)
            builder.reference(from: \.unitId, to: \Unit.id, onDelete: .cascade)
            builder.reference(from: \.modelId, to: \Model.id, onDelete: .cascade)
            builder.unique(on: \.unitId, \.modelId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UnitModel.self, on: conn)
    }

}
