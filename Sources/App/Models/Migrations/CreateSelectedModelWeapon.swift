import FluentPostgreSQL

struct CreateSelectedModelWeapon: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.create(SelectedModelWeapon.self, on: conn, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.modelId)
            builder.field(for: \.weaponBucketId)
            builder.field(for: \.weaponId)
            builder.unique(on: \.modelId, \.weaponBucketId)
            builder.reference(from: \.modelId, to: \SelectedModel.id, onDelete: .cascade)
            builder.reference(from: \.weaponBucketId, to: \WeaponBucket.id, onDelete: .cascade)
            builder.reference(from: \.weaponId, to: \Weapon.id, onDelete: .cascade)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.delete(SelectedModelWeapon.self, on: conn)
    }
}
