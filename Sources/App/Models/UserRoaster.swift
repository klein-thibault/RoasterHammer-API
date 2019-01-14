import Vapor
import FluentPostgreSQL

final class UserRoaster: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Customer
    typealias Right = Roaster

    static var leftIDKey: WritableKeyPath<UserRoaster, Int> = \.userId
    static var rightIDKey: WritableKeyPath<UserRoaster, Int> = \.roasterId

    var id: Int?
    var userId: Int
    var roasterId: Int

    init(_ left: Customer, _ right: Roaster) throws {
        userId = try left.requireID()
        roasterId = try right.requireID()
    }
}

extension UserRoaster: Content { }
