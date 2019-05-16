import Vapor

enum RoasterHammerTreeError: Swift.Error {
    case nodeIsInvalid
    case missingNodesInDatabase
    case treeIsEmpty
}

enum RoasterHammerError: Swift.Error {
    case ruleIsMissing
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
    case weaponBucketIsMissing
    case characteristicsAreMissing
    case relicIsMissing
    case keywordIsMissing
    case addingUnitToWrongRole
    case addingUniqueUnitMoreThanOnce
    case tooManyUnitsInDetachment
    case tooManyModelsInUnit
    case tooFewModelsInUnit
    case tooManyWeaponsForModel
    case costIsNotANumber
    case tooManyWeaponSelectionFromWeaponBucket
    case warlordSelectionInvalidRole
}

extension RoasterHammerError {
    func error() -> AbortError {
        switch self {
        case .ruleIsMissing:
            return Abort(.badRequest, reason: "The rule could not be found")
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
        case .weaponBucketIsMissing:
            return Abort(.badRequest, reason: "The weapon bucket could not be found")
        case .characteristicsAreMissing:
            return Abort(.badRequest, reason: "The model characteristics could not be found")
        case .relicIsMissing:
            return Abort(.badRequest, reason: "The relic could not be found")
        case .keywordIsMissing:
            return Abort(.badRequest, reason: "The keyword could not be found")
        case .addingUnitToWrongRole:
            return Abort(.badRequest, reason: "Can't add this unit to this detachment role")
        case .addingUniqueUnitMoreThanOnce:
            return Abort(.badRequest, reason: "Can't add a unique unit more than once")
        case .tooManyUnitsInDetachment:
            return Abort(.badRequest, reason: "There are too many units in this detachment")
        case .tooManyModelsInUnit:
            return Abort(.badRequest, reason: "There are too many models in this unit")
        case .tooFewModelsInUnit:
            return Abort(.badRequest, reason: "Cannot remove more models from this unit")
        case .tooManyWeaponsForModel:
            return Abort(.badRequest, reason: "The model has reached its maximum of weapons")
        case .costIsNotANumber:
            return Abort(.badRequest, reason: "The cost must be a number")
        case .tooManyWeaponSelectionFromWeaponBucket:
            return Abort(.badRequest, reason: "Can't select more weapons from this weapon bucket")
        case .warlordSelectionInvalidRole:
            return Abort(.badRequest, reason: "Your warlord selection must be a \(Constants.RoleName.hq)")
        }
    }
}
