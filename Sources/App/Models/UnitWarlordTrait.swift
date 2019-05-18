import Vapor
import FluentPostgreSQL

final class UnitWarlordTrait: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Unit
    typealias Right = WarlordTrait

    static var leftIDKey: WritableKeyPath<UnitWarlordTrait, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<UnitWarlordTrait, Int> = \.warlordTraitId

    var id: Int?
    var unitId: Int
    var warlordTraitId: Int

    init(_ left: Unit, _ right: WarlordTrait) throws {
        unitId = try left.requireID()
        warlordTraitId = try right.requireID()
    }
}

extension UnitWarlordTrait: Content { }
