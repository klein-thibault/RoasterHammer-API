@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class TreeTests: BaseTests {

    private func setupTestTree() throws -> Tree<String> {
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

        return tree
    }

    func testTreeCreation() throws {
        let tree = try setupTestTree()
        let treeDatastore = TreeDatastore()
        let nodeElementClosures = try treeDatastore.storeTreeToDatabase(tree, on: conn).wait()

        let nodeElement1 = try NodeElement.query(on: conn).filter(\.elementId == "1").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()
        let nodeElement2 = try NodeElement.query(on: conn).filter(\.elementId == "2").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()
        let nodeElement3 = try NodeElement.query(on: conn).filter(\.elementId == "3").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()
        let nodeElement4 = try NodeElement.query(on: conn).filter(\.elementId == "4").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()
        let nodeElement5 = try NodeElement.query(on: conn).filter(\.elementId == "5").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()
        let nodeElement6 = try NodeElement.query(on: conn).filter(\.elementId == "6").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()
        let nodeElement7 = try NodeElement.query(on: conn).filter(\.elementId == "7").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()

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

    func testTreeInsertion() throws {
        let tree = try setupTestTree()
        let treeDatastore = TreeDatastore()
        _ = try treeDatastore.storeTreeToDatabase(tree, on: conn).wait()

        guard let nodeToInsertFrom = tree.search("5") else {
            XCTFail("Could not find the expected node with value 5")
            return
        }

        let insertedNode = try treeDatastore.insertValue("8", nodeType: .detachment, atNode: nodeToInsertFrom, fromTree: tree, conn: conn).wait()
        XCTAssertEqual(insertedNode.ancestor, insertedNode.descendant)
        XCTAssertEqual(insertedNode.depth, 0)

        let ancestors = try treeDatastore.ancestorsOfDescendant(insertedNode.ancestor, conn: conn).wait()
        XCTAssertEqual(ancestors.count, 4)
        XCTAssertEqual(ancestors[0].ancestor, 1)
        XCTAssertEqual(ancestors[0].depth, 3)
        XCTAssertEqual(ancestors[1].ancestor, 4)
        XCTAssertEqual(ancestors[1].depth, 2)
        XCTAssertEqual(ancestors[2].ancestor, 5)
        XCTAssertEqual(ancestors[2].depth, 1)
        XCTAssertEqual(ancestors[3].ancestor, 8)
        XCTAssertEqual(ancestors[3].depth, 0)
    }

    func testAncestorsOfDescendant() throws {
        let tree = try setupTestTree()
        let treeDatastore = TreeDatastore()
        _ = try treeDatastore.storeTreeToDatabase(tree, on: conn).wait()

        let descendant = try NodeElement.query(on: conn).filter(\.elementId == "5").first().unwrap(or: RoasterHammerTreeError.missingNodesInDatabase).wait()

        let ancestors = try treeDatastore.ancestorsOfDescendant(descendant.id!, conn: conn).wait()
        XCTAssertEqual(ancestors.count, 3)
        XCTAssertEqual(ancestors[0].ancestor, 1)
        XCTAssertEqual(ancestors[1].ancestor, 4)
        XCTAssertEqual(ancestors[2].ancestor, 5)
    }

    func testTreeFromDatabase() throws {
        let tree = try setupTestTree()
        let treeDatastore = TreeDatastore()
        _ = try treeDatastore.storeTreeToDatabase(tree, on: conn).wait()

        let treeRoot = tree.root!
        let treeFromDatabase = try treeDatastore.createTreeFromRoot(treeRoot, conn: conn).wait()

        var allTreeNodes: [String] = []
        tree.root?.forEachLevelFirst(visit: { testTreeNode in
            allTreeNodes.append(testTreeNode.value)
        })

        var allDatabaseTreeNodes: [String] = []
        treeFromDatabase.root?.forEachLevelFirst(visit: { databaseTreeNode in
            allDatabaseTreeNodes.append(String(databaseTreeNode.value))
        })

        XCTAssertEqual(allTreeNodes.count, allDatabaseTreeNodes.count)
        for i in 0...allTreeNodes.count - 1 {
            XCTAssertEqual(allTreeNodes[i], allDatabaseTreeNodes[i])
        }
    }

    func testCreateRoasterTreeFromDatabaseTree() throws {
        let tree = try setupTestTree()
        let treeDatastore = TreeDatastore()
        _ = try treeDatastore.storeTreeToDatabase(tree, on: conn).wait()

        let treeRoot = tree.root!
        let treeFromDatabase = try treeDatastore.createTreeFromRoot(treeRoot, conn: conn).wait()

        let roasterTree = try treeDatastore.createRoasterTreeFromDatabaseTree(treeFromDatabase, conn: conn).wait()
        XCTAssertNotNil(roasterTree.root)

        var allTreeNodes: [String] = []
        tree.root?.forEachLevelFirst(visit: { testTreeNode in
            allTreeNodes.append(testTreeNode.value)
        })

        var allRoasterTreeNodes: [String] = []
        roasterTree.root?.forEachLevelFirst(visit: { roasterTreeNode in
            allRoasterTreeNodes.append(roasterTreeNode.value.elementId)
        })

        XCTAssertEqual(allTreeNodes.count, allRoasterTreeNodes.count)
        for i in 0...allTreeNodes.count - 1 {
            XCTAssertEqual(allTreeNodes[i], allRoasterTreeNodes[i])
        }
    }

}
