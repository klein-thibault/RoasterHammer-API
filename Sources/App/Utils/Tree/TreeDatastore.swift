import Vapor
import FluentPostgreSQL

final class TreeDatastore {

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
