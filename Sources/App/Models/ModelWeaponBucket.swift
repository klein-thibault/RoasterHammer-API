import Vapor
import FluentPostgreSQL

final class ModelWeaponBucket: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Model
    typealias Right = WeaponBucket

    static var leftIDKey: WritableKeyPath<ModelWeaponBucket, Int> = \.modelId
    static var rightIDKey: WritableKeyPath<ModelWeaponBucket, Int> = \.weaponBucketId

    var id: Int?
    var modelId: Int
    var weaponBucketId: Int

    init(_ left: Model, _ right: WeaponBucket) throws {
        modelId = try left.requireID()
        weaponBucketId = try right.requireID()
    }
}

extension ModelWeaponBucket: Content { }
