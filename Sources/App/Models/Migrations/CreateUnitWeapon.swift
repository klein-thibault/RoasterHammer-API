import FluentPostgreSQL

struct CreateUnitWeapon: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(UnitWeapon.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.unitId)
            builder.field(for: \.weaponId)
            builder.field(for: \.isSelected)
            builder.reference(from: \.unitId, to: \Unit.id, onDelete: .cascade)
            builder.reference(from: \.weaponId, to: \Weapon.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(UnitWeapon.self, on: conn)
    }
}
