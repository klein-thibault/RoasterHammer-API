import Foundation

extension Array where Element: Hashable {
    func subtracting(_ array: [Element]) -> [Element] {
        let set1 = Set(self)
        let set2 = Set(array)
        return Array(set1.subtracting(set2))
    }
}
