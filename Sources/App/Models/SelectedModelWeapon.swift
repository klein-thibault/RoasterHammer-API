import Vapor
import FluentPostgreSQL

final class SelectedModelWeapon: PostgreSQLPivot, ModifiablePivot {

    typealias Left = SelectedModel
    typealias Right = Weapon

    static var leftIDKey: WritableKeyPath<SelectedModelWeapon, Int> = \.modelId
    static var rightIDKey: WritableKeyPath<SelectedModelWeapon, Int> = \.weaponId

    var id: Int?
    var modelId: Int
    var weaponId: Int

    init(_ left: SelectedModel, _ right: Weapon) throws {
        modelId = try left.requireID()
        weaponId = try right.requireID()
    }

}

extension SelectedModelWeapon: Content { }
