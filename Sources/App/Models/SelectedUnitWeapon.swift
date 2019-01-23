import Vapor
import FluentPostgreSQL

final class SelectedUnitWeapon: PostgreSQLPivot, ModifiablePivot {

    typealias Left = SelectedUnit
    typealias Right = Weapon

    static var leftIDKey: WritableKeyPath<SelectedUnitWeapon, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<SelectedUnitWeapon, Int> = \.weaponId

    var id: Int?
    var unitId: Int
    var weaponId: Int

    init(_ left: SelectedUnit, _ right: Weapon) throws {
        unitId = try left.requireID()
        weaponId = try right.requireID()
    }

}

extension SelectedUnitWeapon: Content { }
