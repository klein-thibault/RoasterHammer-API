import FluentPostgreSQL

struct CreateWeaponBucketWeapon: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(WeaponBucketWeapon.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.weaponBucketId)
            builder.field(for: \.weaponId)
            builder.reference(from: \.weaponBucketId, to: \WeaponBucket.id, onDelete: .cascade)
            builder.reference(from: \.weaponId, to: \Weapon.id, onDelete: .cascade)
            builder.unique(on: \.weaponBucketId, \.weaponId)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(WeaponBucketWeapon.self, on: conn)
    }
}
