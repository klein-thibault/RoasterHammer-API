import Vapor
import FluentPostgreSQL

final class RoasterRule: PostgreSQLPivot {
    typealias Left = Roaster
    typealias Right = Rule

    static var leftIDKey: WritableKeyPath<RoasterRule, Int> = \.roasterId
    static var rightIDKey: WritableKeyPath<RoasterRule, Int> = \.ruleId

    var id: Int?
    var roasterId: Int
    var ruleId: Int

    init(_ left: Game, _ right: Rule) throws {
        roasterId = try left.requireID()
        ruleId = try right.requireID()
    }
}

extension RoasterRule: Content { }
