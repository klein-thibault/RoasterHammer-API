import Vapor
import FluentPostgreSQL

final class SelectedModelWeaponBucket: PostgreSQLPivot, ModifiablePivot {
    typealias Left = SelectedModel
    typealias Right = WeaponBucket

    static var leftIDKey: WritableKeyPath<SelectedModelWeaponBucket, Int> = \.modelId
    static var rightIDKey: WritableKeyPath<SelectedModelWeaponBucket, Int> = \.weaponBucketId

    var id: Int?
    var modelId: Int
    var weaponBucketId: Int

    init(_ left: SelectedModel, _ right: WeaponBucket) throws {
        modelId = try left.requireID()
        weaponBucketId = try right.requireID()
    }
}

extension SelectedModelWeaponBucket: Content { }
