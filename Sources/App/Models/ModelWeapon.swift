import Vapor
import FluentPostgreSQL

final class ModelWeapon: PostgreSQLPivot, ModifiablePivot {

    typealias Left = Model
    typealias Right = Weapon

    static var leftIDKey: WritableKeyPath<ModelWeapon, Int> = \.modelId
    static var rightIDKey: WritableKeyPath<ModelWeapon, Int> = \.weaponId

    var id: Int?
    var modelId: Int
    var weaponId: Int
    var minQuantity: Int = 1
    var maxQuantity: Int = 1

    init(_ left: Model, _ right: Weapon) throws {
        modelId = try left.requireID()
        weaponId = try right.requireID()
    }

}

extension ModelWeapon: Content { }
