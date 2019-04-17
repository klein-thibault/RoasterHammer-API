import Vapor
import FluentPostgreSQL

final class WeaponBucket: PostgreSQLModel {
    var id: Int?
    var name: String
    // TODO: add link between weapon and weapon option
    // and weapon option and weapon

    init(name: String) {
        self.name = name
    }
}

extension WeaponBucket: Content { }
extension WeaponBucket: PostgreSQLMigration { }
