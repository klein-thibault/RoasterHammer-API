import Vapor
import FluentPostgreSQL

final class FactionRule: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Faction
    typealias Right = Rule

    static var leftIDKey: WritableKeyPath<FactionRule, Int> = \.factionId
    static var rightIDKey: WritableKeyPath<FactionRule, Int> = \.ruleId

    var id: Int?
    var factionId: Int
    var ruleId: Int

    init(_ left: Faction, _ right: Rule) throws {
        factionId = try left.requireID()
        ruleId = try right.requireID()
    }
}

extension FactionRule: Content { }
