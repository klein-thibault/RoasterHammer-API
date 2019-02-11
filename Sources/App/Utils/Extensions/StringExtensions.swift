import Foundation

extension String {
    var isCheckboxOn: Bool {
        return self == "on"
    }

    var intValue: Int? {
        return NumberFormatter().number(from: self)?.intValue
    }

}
