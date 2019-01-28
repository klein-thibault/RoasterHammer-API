import Foundation

enum RoasterHammerTreeError: Swift.Error {
    case nodeIsInvalid
    case missingNodesInDatabase
    case treeIsEmpty
}

enum RoasterHammerError: Swift.Error {
    case gameIsMissing
    case roasterIsMissing
    case armyIsMissing
    case detachmentIsMissing
    case roleIsMissing
    case unitIsMissing
    case modelIsMissing
    case weaponIsMissing
    case unitTypeIsMissing
    case factionIsMissing
    case characteristicsAreMissing
}
