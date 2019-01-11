/// Tree node.
final class TreeNode<Element> {
    var value: Element
    var height: Int = 0
    var children: [TreeNode<Element>] = []

    init(_ value: Element) {
        self.value = value
    }

    func add(_ child: TreeNode) {
        self.children.append(child)
    }

    func forEachDepthFirst(visit: (TreeNode) -> Void) {
        visit(self)
        children.forEach {
            $0.forEachDepthFirst(visit: visit)
        }
    }

    func forEachLevelFirst(visit: (TreeNode) -> Void) {
        visit(self)
        let queue = Queue<TreeNode>()
        children.forEach { queue.enqueue($0) }

        while let node = queue.dequeue() {
            visit(node)
            node.children.forEach { queue.enqueue($0) }
        }
    }

}

extension TreeNode where Element: Equatable {

    func search(_ value: Element) -> TreeNode? {
        var result: TreeNode?

        forEachDepthFirst { node in
            if node.value == value {
                result = node
            }
        }

        return result
    }

}
