import Vapor
import FluentPostgreSQL

final class TreeDatastore {

    /// Given a tree, this function will persist all the node and branches in a closure table.
    ///
    /// - Parameters:
    ///   - tree: The tree to persist.
    ///   - conn: The database connection to use.
    /// - Returns: The list of persisted node elements.
    func storeTree(_ tree: Tree<String>, on conn: DatabaseConnectable) -> Future<[NodeElementClosure]> {
        guard let root = tree.root else {
            return conn.eventLoop.newFailedFuture(error: RoasterHammerTreeError.treeIsEmpty)
        }

        var nodeElementClosureFutures: [Future<NodeElementClosure>] = []

        root.forEachDepthFirst { node in
            let queue = Queue<TreeNode<String>>()
            node.forEachDepthFirst(visit: { node in
                queue.enqueue(node)
            })

            while let dequeuedNode = queue.dequeue() {
                let depth = dequeuedNode.height - node.height

                let ancestorFuture = NodeElement.query(on: conn).filter(\.elementId == node.value).first()
                let descendantFuture = NodeElement.query(on: conn).filter(\.elementId == dequeuedNode.value).first()

                let nodeElementClosureFuture = flatMap(ancestorFuture, descendantFuture, { (ancestor, descendant) -> EventLoopFuture<NodeElementClosure> in
                    guard let ancestorId = ancestor?.id, let descendantId = descendant?.id else {
                        return conn.eventLoop.newFailedFuture(error: RoasterHammerTreeError.missingNodesInDatabase)
                    }

                    return NodeElementClosure(ancestor: ancestorId, descendant: descendantId, depth: depth).save(on: conn)
                })

                nodeElementClosureFutures.append(nodeElementClosureFuture)
            }
        }

        return nodeElementClosureFutures.flatten(on: conn)
    }

    /// Returns all the descendants of a given node, including the node itself.
    ///
    /// - Parameters:
    ///   - node: The node to find the descendants from.
    ///   - conn: The database connection.
    /// - Returns: The list of all descendants of the given node.
    func findDescendantsForNode(_ node: NodeElement, on conn: DatabaseConnectable) -> Future<[NodeElement]> {
        return NodeElementClosure.query(on: conn)
            .filter(\.ancestor == node.id!)
            .all()
            .flatMap(to: [NodeElement].self, { nodeElementClosures in
                var nodeElementFutures: [Future<NodeElement>] = []

                for nodeElementClosure in nodeElementClosures {
                    let nodeElementFuture = NodeElement.query(on: conn)
                        .filter(\.id == nodeElementClosure.descendant)
                        .first()
                        .unwrap(or: RoasterHammerTreeError.nodeIsInvalid)
                    nodeElementFutures.append(nodeElementFuture)
                }

                return nodeElementFutures.flatten(on: conn)
        })
    }

}
