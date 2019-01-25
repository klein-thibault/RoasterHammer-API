import Vapor
import FluentPostgreSQL

final class UnitKeyword: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Unit
    typealias Right = Keyword

    static var leftIDKey: WritableKeyPath<UnitKeyword, Int> = \.unitId
    static var rightIDKey: WritableKeyPath<UnitKeyword, Int> = \.keywordId

    var id: Int?
    var unitId: Int
    var keywordId: Int

    init(_ left: Unit, _ right: Keyword) throws {
        unitId = try left.requireID()
        keywordId = try right.requireID()
    }
}

extension UnitKeyword: Content { }
