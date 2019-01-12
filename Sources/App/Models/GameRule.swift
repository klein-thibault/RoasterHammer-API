import Vapor
import FluentPostgreSQL

final class GameRule: PostgreSQLPivot {
    typealias Left = Game
    typealias Right = Rule

    static var leftIDKey: WritableKeyPath<GameRule, Int> = \.gameId
    static var rightIDKey: WritableKeyPath<GameRule, Int> = \.ruleId

    var id: Int?
    var gameId: Int
    var ruleId: Int

    init(_ left: Game, _ right: Rule) throws {
        gameId = try left.requireID()
        ruleId = try right.requireID()
    }

}

extension GameRule: Content { }
