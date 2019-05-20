import Vapor
import FluentPostgreSQL

final class PsychicPower: PostgreSQLModel {
    var id: Int?
    var name: String
    var description: String
    var keywords: Siblings<PsychicPower, Keyword, PsychicPowerKeyword> {
        return siblings()
    }
}

extension PsychicPower: Content { }
extension PsychicPower: PostgreSQLMigration { }
