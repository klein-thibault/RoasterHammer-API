import Vapor
import FluentPostgreSQL

enum NodeType: String {
    case game
    case roaster
    case army
    case detachment
    case unitType
    case unit
    case weapon
}

/// Represents a node in the game roaster tree.
final class NodeElement: PostgreSQLModel {
    var id: Int?
    var elementId: String
    var type: String

    init(elementId: String, type: String) {
        self.elementId = elementId
        self.type = type
    }
}

extension NodeElement: Content { }
extension NodeElement: PostgreSQLMigration { }
