import Vapor
import FluentPostgreSQL

final class UnitPsychicPower: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Unit
    typealias Right = PsychicPower

    static var leftIDKey: WritableKeyPath<UnitPsychicPower, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<UnitPsychicPower, Int> = \.psychicPowerId

    var id: Int?
    var unitId: Int
    var psychicPowerId: Int

    init(_ left: Unit, _ right: PsychicPower) throws {
        unitId = try left.requireID()
        psychicPowerId = try right.requireID()
    }
}

extension UnitPsychicPower: Content { }
