import Vapor

struct CreateUnitRequest: Content {
    let name: String
    let cost: Int
    let isUnique: Bool
    let minQuantity: Int
    let maxQuantity: Int
    let unitTypeId: Int
    let characteristics: CharacteristicsRequest
    let keywords: [UnitKeywordRequest]
    let rules: [AddRuleRequest]
}

struct CharacteristicsRequest: Content {
    let movement: String
    let weaponSkill: String
    let balisticSkill: String
    let strength: String
    let toughness: String
    let wounds: String
    let attacks: String
    let leadership: String
    let save: String
}

struct UnitKeywordRequest: Content {
    let name: String
}
