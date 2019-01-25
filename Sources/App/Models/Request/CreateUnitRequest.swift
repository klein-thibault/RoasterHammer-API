import Vapor

struct CreateUnitRequest: Content {
    var name: String
    var cost: Int
    var isUnique: Bool
    var unitTypeId: Int
    var characteristics: CharacteristicsRequest
    var keywords: [UnitKeywordRequest]
    var rules: [AddRuleRequest]
}

struct CharacteristicsRequest: Content {
    var movement: String
    var weaponSkill: String
    var balisticSkill: String
    var strength: String
    var toughness: String
    var wounds: String
    var attacks: String
    var leadership: String
    var save: String
}

struct UnitKeywordRequest: Content {
    var name: String
}
