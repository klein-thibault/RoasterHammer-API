import Vapor
import FluentPostgreSQL

final class SelectedUnitModel: PostgreSQLPivot, ModifiablePivot {

    typealias Left = SelectedUnit
    typealias Right = SelectedModel

    static var leftIDKey: WritableKeyPath<SelectedUnitModel, Int> = \.selectedUnitId
    static var rightIDKey: WritableKeyPath<SelectedUnitModel, Int> = \.selectedModelId

    var id: Int?
    var selectedUnitId: Int
    var selectedModelId: Int

    init(_ left: SelectedUnit, _ right: SelectedModel) throws {
        selectedUnitId = try left.requireID()
        selectedModelId = try right.requireID()
    }

}

extension SelectedUnitModel: Content { }
