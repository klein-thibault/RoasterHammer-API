import Vapor
import FluentPostgreSQL

final class SelectedUnitModel: PostgreSQLPivot, ModifiablePivot {

    typealias Left = SelectedUnit
    typealias Right = SelectedModel

    static var leftIDKey: WritableKeyPath<SelectedUnitModel, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<SelectedUnitModel, Int> = \.modelId

    var id: Int?
    var unitId: Int
    var modelId: Int

    init(_ left: SelectedUnit, _ right: SelectedModel) throws {
        unitId = try left.requireID()
        modelId = try right.requireID()
    }

}

extension SelectedUnitModel: Content { }
