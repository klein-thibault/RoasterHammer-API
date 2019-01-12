/// Tree data structure.
final class Tree<T> {
    var root: TreeNode<T>?

    var isEmpty: Bool {
        return root == nil
    }

    init() {}

    func insert(_ value: T) -> TreeNode<T> {
        return insert(atNode: root, value: value)
    }

    @discardableResult
    func insert(atNode node: TreeNode<T>?, value: T) -> TreeNode<T> {
        let newNode = TreeNode(value)

        guard let node = node else {
            root = newNode
            return newNode
        }

        newNode.height = node.height + 1
        node.add(newNode)
        return newNode
    }

}

extension Tree where T: Equatable {

    func search(_ value: T) -> TreeNode<T>? {
        return root?.search(value)
    }

}
