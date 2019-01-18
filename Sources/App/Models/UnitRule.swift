import Vapor
import FluentPostgreSQL

final class UnitRule: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Unit
    typealias Right = Rule

    static var leftIDKey: WritableKeyPath<UnitRule, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<UnitRule, Int> = \.ruleId

    var id: Int?
    var unitId: Int
    var ruleId: Int

    init(_ left: Unit, _ right: Rule) throws {
        unitId = try left.requireID()
        ruleId = try right.requireID()
    }

}

extension UnitRule: Content { }
