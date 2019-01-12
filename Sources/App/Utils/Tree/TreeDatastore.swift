import Vapor
import FluentPostgreSQL

final class TreeDatastore {

    /// Given a tree, this function will persist all the node and branches in a closure table.
    ///
    /// - Parameters:
    ///   - tree: The tree to persist.
    ///   - conn: The database connection to use.
    /// - Returns: The list of persisted node elements.
    func storeTreeToDatabase(_ tree: Tree<String>, on conn: DatabaseConnectable) -> Future<[NodeElementClosure]> {
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

    func createTreeFromRoot(_ root: TreeNode<String>, conn: DatabaseConnectable) -> Future<Tree<Int>> {
        return NodeElement
            .query(on: conn)
            .filter(\.elementId == root.value)
            .first()
            .unwrap(or: RoasterHammerTreeError.missingNodesInDatabase)
            .flatMap(to: NodeElementClosure.self, { rootElement in
                return NodeElementClosure
                    .query(on: conn)
                    .filter(\.ancestor == rootElement.id!)
                    .filter(\.depth == 0)
                    .first()
                    .unwrap(or: RoasterHammerTreeError.missingNodesInDatabase)
            })
            .flatMap(to: Tree<Int>.self) { root in
                let tree = Tree<Int>()
                return self.addDatabaseNodeToTree(tree: tree, parentNode: nil, node: root, conn: conn)
        }
    }

    func insertValue(_ value: String,
                     nodeType: NodeType,
                     atNode nodeReceiver: TreeNode<String>,
                     fromTree tree: Tree<String>,
                     conn: DatabaseConnectable) -> Future<NodeElementClosure> {
        let insertedNode = tree.insert(atNode: nodeReceiver, value: value)
        let nodeElementToInsert = NodeElement(elementId: insertedNode.value, type: nodeType.rawValue).save(on: conn)
        let nodeElementReceiver = NodeElement
            .query(on: conn)
            .filter(\.elementId == nodeReceiver.value)
            .first()
            .unwrap(or: RoasterHammerTreeError.missingNodesInDatabase)

        return flatMap(nodeElementToInsert, nodeElementReceiver) { (nodeToInsert, nodeReceiver) -> EventLoopFuture<NodeElementClosure> in
            guard let nodeToInsertId = nodeToInsert.id,
                let nodeReceiverId = nodeReceiver.id else {
                    return conn.eventLoop.newFailedFuture(error: RoasterHammerTreeError.nodeIsInvalid)
            }

            return self.ancestorsOfDescendant(nodeReceiverId, conn: conn)
                .flatMap(to: [NodeElementClosure].self, { ancestors in
                var futures: [Future<NodeElementClosure>] = []
                for ancestor in ancestors {
                    let nodeElementClosureFuture = NodeElementClosure(ancestor: ancestor.ancestor,
                                                                      descendant: nodeToInsertId,
                                                                      depth: ancestor.depth + 1).save(on: conn)
                    futures.append(nodeElementClosureFuture)
                }

                return futures.flatten(on: conn)
            }).flatMap(to: NodeElementClosure.self, { _ in
                return NodeElementClosure(ancestor: nodeToInsertId, descendant: nodeToInsertId, depth: 0).save(on: conn)
            })
        }
    }

    /// Returns all the ancestors of the given descendant ID.
    ///
    /// - Parameters:
    ///   - descendantId: The descendant ID to use.
    ///   - conn: The database connection.
    /// - Returns: The ancestors of the given descendant ID.
    func ancestorsOfDescendant(_ descendantId: Int, conn: DatabaseConnectable) -> Future<[NodeElementClosure]> {
        return NodeElementClosure.query(on: conn).filter(\.descendant == descendantId).all()
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

    // MARK: - Private Functions

    private func nodeChildren(_ node: NodeElementClosure, conn: DatabaseConnectable) -> Future<[NodeElementClosure]> {
        return NodeElementClosure
            .query(on: conn)
            .filter(\.ancestor == node.descendant)
            .filter(\.depth == 1)
            .all()
    }

    private func addDatabaseNodeToTree(tree: Tree<Int>, parentNode: TreeNode<Int>?, node: NodeElementClosure, conn: DatabaseConnectable) -> Future<Tree<Int>> {
        let insertedNode = tree.insert(atNode: parentNode, value: node.descendant)

        return self.nodeChildren(node, conn: conn).flatMap(to: Tree<Int>.self) { children in
            if children.isEmpty {
                return conn.future(tree)
            }

            var futures: [Future<Tree<Int>>] = []
            for child in children {
                futures.append(self.addDatabaseNodeToTree(tree: tree, parentNode: insertedNode, node: child, conn: conn))
            }

            return futures.flatten(on: conn).then({ (trees) -> EventLoopFuture<Tree<Int>> in
                return conn.future(trees.last!)
            })
        }
    }

//    private func createRoasterTreeFromDatabaseTree(_ databaseTree: Tree<Int>, conn: DatabaseConnectable) -> Future<Tree<NodeElement>> {
//        guard let root = databaseTree.root else {
//            return conn.future(error: RoasterHammerTreeError.treeIsEmpty)
//        }
//
//        root.forEachLevelFirst(visit: <#T##(TreeNode<Int>) -> Void#>)
//    }

}
