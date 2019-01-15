import Vapor
import FluentPostgreSQL

final class ArmyRule: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Army
    typealias Right = Rule

    static var leftIDKey: WritableKeyPath<ArmyRule, Int> = \.armyId
    static var rightIDKey: WritableKeyPath<ArmyRule, Int> = \.ruleId

    var id: Int?
    var armyId: Int
    var ruleId: Int

    init(_ left: Army, _ right: Rule) throws {
        armyId = try left.requireID()
        ruleId = try right.requireID()
    }
}

extension ArmyRule: Content { }
