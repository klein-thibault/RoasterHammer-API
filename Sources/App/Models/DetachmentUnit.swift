import Vapor
import FluentPostgreSQL

final class DetachmentUnit: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Detachment
    typealias Right = UnitRole

    static var leftIDKey: WritableKeyPath<DetachmentUnit, Int> = \.detachmentId
    static var rightIDKey: WritableKeyPath<DetachmentUnit, Int> = \.unitRoleId

    var id: Int?
    var detachmentId: Int
    var unitRoleId: Int

    init(_ left: Detachment, _ right: UnitRole) throws {
        detachmentId = try left.requireID()
        unitRoleId = try right.requireID()
    }

}

extension DetachmentUnit: Content { }
