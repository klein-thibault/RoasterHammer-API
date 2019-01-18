import Vapor
import FluentPostgreSQL

final class UnitRole: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Unit
    typealias Right = Role

    static var leftIDKey: WritableKeyPath<UnitRole, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<UnitRole, Int> = \.roleId

    var id: Int?
    var unitId: Int
    var roleId: Int

    init(_ left: Unit, _ right: Role) throws {
        unitId = try left.requireID()
        roleId = try right.requireID()
    }

}

extension UnitRole: Content { }
