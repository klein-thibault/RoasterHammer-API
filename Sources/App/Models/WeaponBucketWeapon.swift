import Vapor
import FluentPostgreSQL

final class WeaponBucketWeapon: PostgreSQLPivot, ModifiablePivot {
    typealias Left = WeaponBucket
    typealias Right = Weapon

    static var leftIDKey: WritableKeyPath<WeaponBucketWeapon, Int> = \.weaponBucketId
    static var rightIDKey: WritableKeyPath<WeaponBucketWeapon, Int> = \.weaponId

    var id: Int?
    var weaponBucketId: Int
    var weaponId: Int

    init(_ left: WeaponBucket, _ right: Weapon) throws {
        weaponBucketId = try left.requireID()
        weaponId = try right.requireID()
    }
}

extension WeaponBucketWeapon: Content { }
