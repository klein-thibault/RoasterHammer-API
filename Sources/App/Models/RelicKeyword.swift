import Vapor
import FluentPostgreSQL

final class RelicKeyword: PostgreSQLPivot, ModifiablePivot {
    typealias Left = Relic
    typealias Right = Keyword

    static var leftIDKey: WritableKeyPath<RelicKeyword, Int> = \.relicId
    static var rightIDKey: WritableKeyPath<RelicKeyword, Int> = \.keywordId

    var id: Int?
    var relicId: Int
    var keywordId: Int

    init(_ left: Relic, _ right: Keyword) throws {
        relicId = try left.requireID()
        keywordId = try right.requireID()
    }
}

extension RelicKeyword: Content { }
