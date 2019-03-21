import FluentPostgreSQL

struct CreateSelectedUnitModel: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(SelectedUnitModel.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.selectedUnitId)
            builder.field(for: \.selectedModelId)
            builder.reference(from: \.selectedUnitId, to: \SelectedUnit.id, onDelete: .cascade)
            builder.reference(from: \.selectedModelId, to: \SelectedModel.id, onDelete: .cascade)
            builder.unique(on: \.selectedUnitId, \.selectedModelId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(SelectedUnitModel.self, on: conn)
    }

}
