import Vapor
import FluentPostgreSQL

final class ArmyDetachment: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Army
    typealias Right = Detachment

    static var leftIDKey: WritableKeyPath<ArmyDetachment, Int> = \.armyId
    static var rightIDKey: WritableKeyPath<ArmyDetachment, Int> = \.detachmentId

    var id: Int?
    var armyId: Int
    var detachmentId: Int

    init(_ left: Army, _ right: Detachment) throws {
        armyId = try left.requireID()
        detachmentId = try right.requireID()
    }

}

extension ArmyDetachment: Content { }
