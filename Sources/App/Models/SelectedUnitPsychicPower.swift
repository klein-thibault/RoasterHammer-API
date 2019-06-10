import Vapor
import FluentPostgreSQL

final class SelectedUnitPsychicPower: PostgreSQLPivot, ModifiablePivot {
    typealias Left = SelectedUnit
    typealias Right = PsychicPower

    static var leftIDKey: WritableKeyPath<SelectedUnitPsychicPower, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<SelectedUnitPsychicPower, Int> = \.psychicPowerId

    var id: Int?
    var unitId: Int
    var psychicPowerId: Int

    init(_ left: SelectedUnit, _ right: PsychicPower) throws {
        unitId = try left.requireID()
        psychicPowerId = try right.requireID()
    }
}

extension SelectedUnitPsychicPower: Content { }
