import Vapor
import FluentPostgreSQL

final class Detachment: PostgreSQLModel {
    var id: Int?
    var name: String
    var commandPoints: Int
    var armyId: Int
    var factionId: Int?
    var roasters: Siblings<Detachment, Roaster, RoasterDetachment> {
        return siblings()
    }
    var roles: Children<Detachment, Role> {
        return children(\.detachmentId)
    }
    var army: Parent<Detachment, Army> {
        return parent(\.armyId)
    }

    init(name: String, commandPoints: Int, armyId: Int) {
        self.name = name
        self.commandPoints = commandPoints
        self.armyId = armyId
    }

}

extension Detachment: Content { }
extension Detachment: PostgreSQLMigration { }
