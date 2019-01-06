import Vapor
import FluentPostgreSQL

/// Creates the NodeElementClosure table.
final class CreateNodeElementClosure: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(NodeElementClosure.self, on: conn, closure: { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.ancestor)
            builder.field(for: \.descendant)
            builder.field(for: \.depth)
            builder.unique(on: \.ancestor, \.descendant)
            builder.reference(from: \.ancestor, to: \NodeElement.id, onDelete: .cascade)
            builder.reference(from: \.descendant, to: \NodeElement.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(NodeElementClosure.self, on: conn)
    }

}
