final class Queue<Element> {
    private var leftStack: [Element] = []
    private var rightStack: [Element] = []

    public init() {}

    public var isEmpty: Bool {
        return leftStack.isEmpty && rightStack.isEmpty
    }

    public var peek: Element? {
        return !leftStack.isEmpty ? leftStack.last : rightStack.first
    }

    @discardableResult public func enqueue(_ element: Element) -> Bool {
        rightStack.append(element)
        return true
    }

    public func dequeue() -> Element? {
        if leftStack.isEmpty {
            leftStack = rightStack.reversed()
            rightStack.removeAll()
        }
        return leftStack.popLast()
    }
}
