import Vapor
import FluentPostgreSQL

final class RoasterArmy: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Roaster
    typealias Right = Army

    static var leftIDKey: WritableKeyPath<RoasterArmy, Int> = \.roasterId
    static var rightIDKey: WritableKeyPath<RoasterArmy, Int> = \.armyId

    var id: Int?
    var roasterId: Int
    var armyId: Int

    init(_ left: Roaster, _ right: Army) throws {
        roasterId = try left.requireID()
        armyId = try right.requireID()
    }

}

extension RoasterArmy: Content { }
