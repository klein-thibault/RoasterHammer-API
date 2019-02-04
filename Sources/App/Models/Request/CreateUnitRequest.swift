import Vapor

struct CreateUnitRequest: Content {
    let name: String
    let cost: Int
    let isUnique: Bool
    let minQuantity: Int
    let maxQuantity: Int
    let unitTypeId: Int
    let armyId: Int
    let models: [CreateModelRequest]
    let keywords: [String]
    let rules: [AddRuleRequest]
}

struct CreateModelRequest: Content {
    let name: String
    let minQuantity: Int
    let maxQuantity: Int
    let weaponQuantity: Int
    let characteristics: CreateCharacteristicsRequest
}

struct CreateCharacteristicsRequest: Content {
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
