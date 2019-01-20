import Vapor
import FluentPostgreSQL

final class RoasterDetachment: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Roaster
    typealias Right = Detachment

    static var leftIDKey: WritableKeyPath<RoasterDetachment, Int> = \.roasterId
    static var rightIDKey: WritableKeyPath<RoasterDetachment, Int> = \.detachmentId

    var id: Int?
    var roasterId: Int
    var detachmentId: Int

    init(_ left: Roaster, _ right: Detachment) throws {
        roasterId = try left.requireID()
        detachmentId = try right.requireID()
    }

}

extension RoasterDetachment: Content { }
