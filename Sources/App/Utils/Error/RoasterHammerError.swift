import Vapor

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
    case addingUnitToWrongRole
    case tooManyUnitsInDetachment

    func error() -> AbortError {
        switch self {
        case .gameIsMissing:
            return Abort(.badRequest, reason: "The game could not be found")
        case .roasterIsMissing:
            return Abort(.badRequest, reason: "The roaster could not be found")
        case .armyIsMissing:
            return Abort(.badRequest, reason: "The army could not be found")
        case .detachmentIsMissing:
            return Abort(.badRequest, reason: "The detachment could not be found")
        case .roleIsMissing:
            return Abort(.badRequest, reason: "The role could not be found")
        case .unitIsMissing:
            return Abort(.badRequest, reason: "The unit could not be found")
        case .modelIsMissing:
            return Abort(.badRequest, reason: "The model could not be found")
        case .weaponIsMissing:
            return Abort(.badRequest, reason: "The weapon could not be found")
        case .unitTypeIsMissing:
            return Abort(.badRequest, reason: "The unit type could not be found")
        case .factionIsMissing:
            return Abort(.badRequest, reason: "The faction could not be found")
        case .characteristicsAreMissing:
            return Abort(.badRequest, reason: "The model characteristics could not be found")
        case .addingUnitToWrongRole:
            return Abort(.badRequest, reason: "Can't add this unit to this detachment role")
        case .tooManyUnitsInDetachment:
            return Abort(.badRequest, reason: "There are too many units in this detachment")
        }
    }
}
