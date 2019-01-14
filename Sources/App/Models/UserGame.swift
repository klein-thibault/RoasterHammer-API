import Vapor
import FluentPostgreSQL

final class UserGame: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Customer
    typealias Right = Game

    static var leftIDKey: WritableKeyPath<UserGame, Int> = \.userId
    static var rightIDKey: WritableKeyPath<UserGame, Int> = \.gameId

    var id: Int?
    var userId: Int
    var gameId: Int

    init(_ left: Customer, _ right: Game) throws {
        userId = try left.requireID()
        gameId = try right.requireID()
    }
}

extension UserGame: Content { }
