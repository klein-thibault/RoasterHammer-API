import Vapor
import FluentPostgreSQL

final class PsychicPowerKeyword: PostgreSQLPivot, ModifiablePivot {
    typealias Left = PsychicPower
    typealias Right = Keyword

    static var leftIDKey: WritableKeyPath<PsychicPowerKeyword, Int> = \.psychicPowerId
    static var rightIDKey: WritableKeyPath<PsychicPowerKeyword, Int> = \.keywordId

    var id: Int?
    var psychicPowerId: Int
    var keywordId: Int

    init(_ left: PsychicPower, _ right: Keyword) throws {
        psychicPowerId = try left.requireID()
        keywordId = try right.requireID()
    }
}

extension PsychicPowerKeyword: Content { }
