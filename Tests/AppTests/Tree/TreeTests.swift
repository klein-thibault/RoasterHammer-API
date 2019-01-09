@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class TreeTests: BaseTests {

    func testTreeCreation() throws {
        let tree = Tree<String>()
        let node1 = tree.insert("1")
        let node2 = tree.insert(atNode: node1, value: "2")
        let node4 = tree.insert(atNode: node1, value: "4")
        let node3 = tree.insert(atNode: node2, value: "3")
        let node5 = tree.insert(atNode: node4, value: "5")
        let node6 = tree.insert(atNode: node4, value: "6")
        let node7 = tree.insert(atNode: node6, value: "7")

        _ = try NodeElement(elementId: node1.value, type: NodeType.game.rawValue).save(on: conn).wait()
        _ = try NodeElement(elementId: node2.value, type: NodeType.roaster.rawValue).save(on: conn).wait()
        _ = try NodeElement(elementId: node3.value, type: NodeType.army.rawValue).save(on: conn).wait()
        _ = try NodeElement(elementId: node4.value, type: NodeType.roaster.rawValue).save(on: conn).wait()
        _ = try NodeElement(elementId: node5.value, type: NodeType.army.rawValue).save(on: conn).wait()
        _ = try NodeElement(elementId: node6.value, type: NodeType.army.rawValue).save(on: conn).wait()
        _ = try NodeElement(elementId: node7.value, type: NodeType.detachment.rawValue).save(on: conn).wait()

        node1.forEachDepthFirst { (node) in
            let queue = Queue<TreeNode<String>>()
            node.forEachDepthFirst { (node) in
                queue.enqueue(node)
            }

            while let dequeuedNode = queue.dequeue() {
                let depth = dequeuedNode.height - node.height
                do {
                    guard let ancestor = try NodeElement.query(on: conn).filter(\.elementId == node.value).first().wait(),
                        let descendant = try NodeElement.query(on: conn).filter(\.elementId == dequeuedNode.value).first().wait() else {
                        return
                    }

                    _ = try NodeElementClosure(ancestor: ancestor.id!, descendant: descendant.id!, depth: depth).save(on: conn).wait()
                } catch {
                    XCTFail("Failed to create node element closue: \(error)")
                }
            }
        }

    }

}
