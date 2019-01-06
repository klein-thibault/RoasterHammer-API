import Vapor
import FluentPostgreSQL

final class NodeElementClosure: PostgreSQLModel {
    var id: Int?
    var ancestor: Int
    var descendant: Int
    var depth: Int

    init(ancestor: Int, descendant: Int, depth: Int) {
        self.ancestor = ancestor
        self.descendant = descendant
        self.depth = depth
    }
}

extension NodeElementClosure: Content { }
