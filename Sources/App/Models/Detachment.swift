import Vapor
import FluentPostgreSQL

final class Detachment: PostgreSQLModel {
    var id: Int?
    var name: String
    var commandPoints: Int
    var armies: Siblings<Detachment, Army, ArmyDetachment> {
        return siblings()
    }
    var unitRoles: Siblings<Detachment, UnitRole, DetachmentUnit> {
        return siblings()
    }

    init(name: String, commandPoints: Int) {
        self.name = name
        self.commandPoints = commandPoints
    }

}

extension Detachment: Content { }
extension Detachment: PostgreSQLMigration { }
