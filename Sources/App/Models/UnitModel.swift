import Vapor
import FluentPostgreSQL

final class UnitModel: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Unit
    typealias Right = Model

    static var leftIDKey: WritableKeyPath<UnitModel, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<UnitModel, Int> = \.modelId

    var id: Int?
    var unitId: Int
    var modelId: Int

    init(_ left: Unit, _ right: Model) throws {
        unitId = try left.requireID()
        modelId = try right.requireID()
    }

}

extension UnitModel: Content { }
