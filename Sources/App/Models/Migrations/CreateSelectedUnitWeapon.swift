import FluentPostgreSQL

struct CreateSelectedUnitWeapon: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(SelectedUnitWeapon.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.weaponId)
            builder.reference(from: \.unitId, to: \SelectedUnit.id, onDelete: .cascade)
            builder.reference(from: \.weaponId, to: \Weapon.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(SelectedUnitWeapon.self, on: conn)
    }
}
