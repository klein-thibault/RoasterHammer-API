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

        let nodeElement1 = try NodeElement(elementId: node1.value, type: NodeType.game.rawValue).save(on: conn).wait()
        let nodeElement2 = try NodeElement(elementId: node2.value, type: NodeType.roaster.rawValue).save(on: conn).wait()
        let nodeElement3 = try NodeElement(elementId: node3.value, type: NodeType.army.rawValue).save(on: conn).wait()
        let nodeElement4 = try NodeElement(elementId: node4.value, type: NodeType.roaster.rawValue).save(on: conn).wait()
        let nodeElement5 = try NodeElement(elementId: node5.value, type: NodeType.army.rawValue).save(on: conn).wait()
        let nodeElement6 = try NodeElement(elementId: node6.value, type: NodeType.army.rawValue).save(on: conn).wait()
        let nodeElement7 = try NodeElement(elementId: node7.value, type: NodeType.detachment.rawValue).save(on: conn).wait()

        let treeDatastore = TreeDatastore()
        let nodeElementClosures = try treeDatastore.storeTree(tree, on: conn).wait()

        // 1
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 1}.first?.depth, 0)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 2}.first?.depth, 1)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 4}.first?.depth, 1)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 3}.first?.depth, 2)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 5}.first?.depth, 2)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 6}.first?.depth, 2)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 1 && $0.descendant == 7}.first?.depth, 3)

        // 2
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 2 && $0.descendant == 2}.first?.depth, 0)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 2 && $0.descendant == 3}.first?.depth, 1)

        // 3
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 3 && $0.descendant == 3}.first?.depth, 0)

        // 4
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 4 && $0.descendant == 4}.first?.depth, 0)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 4 && $0.descendant == 5}.first?.depth, 1)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 4 && $0.descendant == 6}.first?.depth, 1)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 4 && $0.descendant == 7}.first?.depth, 2)

        // 5
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 5 && $0.descendant == 5}.first?.depth, 0)

        // 6
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 6 && $0.descendant == 6}.first?.depth, 0)
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 6 && $0.descendant == 7}.first?.depth, 1)

        // 7
        XCTAssertEqual(nodeElementClosures.filter { $0.ancestor == 7 && $0.descendant == 7}.first?.depth, 0)

        // 1
        let descendantsOf1 = try treeDatastore.findDescendantsForNode(nodeElement1, on: conn).wait()
        XCTAssertEqual(descendantsOf1.count, 7)
        XCTAssertEqual(descendantsOf1[0].elementId, nodeElement1.elementId)
        XCTAssertEqual(descendantsOf1[0].type, nodeElement1.type)
        XCTAssertEqual(descendantsOf1[1].elementId, nodeElement2.elementId)
        XCTAssertEqual(descendantsOf1[1].type, nodeElement2.type)
        XCTAssertEqual(descendantsOf1[2].elementId, nodeElement3.elementId)
        XCTAssertEqual(descendantsOf1[2].type, nodeElement3.type)
        XCTAssertEqual(descendantsOf1[3].elementId, nodeElement4.elementId)
        XCTAssertEqual(descendantsOf1[3].type, nodeElement4.type)
        XCTAssertEqual(descendantsOf1[4].elementId, nodeElement5.elementId)
        XCTAssertEqual(descendantsOf1[4].type, nodeElement5.type)
        XCTAssertEqual(descendantsOf1[5].elementId, nodeElement6.elementId)
        XCTAssertEqual(descendantsOf1[5].type, nodeElement6.type)
        XCTAssertEqual(descendantsOf1[6].elementId, nodeElement7.elementId)
        XCTAssertEqual(descendantsOf1[6].type, nodeElement7.type)

        // 7
        let descendantsOf7 = try treeDatastore.findDescendantsForNode(nodeElement7, on: conn).wait()
        XCTAssertEqual(descendantsOf7.count, 1)
    }

}
