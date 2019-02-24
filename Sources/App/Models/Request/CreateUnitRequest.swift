import Vapor

typealias KeywordName = String

struct CreateUnitRequest: Content {
    let name: String
    let isUnique: Bool
    let minQuantity: Int
    let maxQuantity: Int
    let unitTypeId: Int
    let armyId: Int
    let models: [CreateModelRequest]
    let keywords: [KeywordName]
    let rules: [AddRuleRequest]

    init(name: String,
         isUnique: Bool,
         minQuantity: Int,
         maxQuantity: Int,
         unitTypeId: Int,
         armyId: Int,
         models: [CreateModelRequest],
         keywords: [KeywordName],
         rules: [AddRuleRequest]) {
        self.name = name
        self.isUnique = isUnique
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.unitTypeId = unitTypeId
        self.armyId = armyId
        self.models = models
        self.keywords = keywords
        self.rules = rules
    }
}

struct CreateModelRequest: Content {
    let name: String
    let cost: Int
    let minQuantity: Int
    let maxQuantity: Int
    let weaponQuantity: Int
    let characteristics: CreateCharacteristicsRequest

    init(name: String,
         cost: Int,
         minQuantity: Int,
         maxQuantity: Int,
         weaponQuantity: Int,
         characteristics: CreateCharacteristicsRequest) {
        self.name = name
        self.cost = cost
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.weaponQuantity = weaponQuantity
        self.characteristics = characteristics
    }
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

    init(movement: String,
         weaponSkill: String,
         balisticSkill: String,
         strength: String,
         toughness: String,
         wounds: String,
         attacks: String,
         leadership: String,
         save: String) {
        self.movement = movement
        self.weaponSkill = weaponSkill
        self.balisticSkill = balisticSkill
        self.strength = strength
        self.toughness = toughness
        self.wounds = wounds
        self.attacks = attacks
        self.leadership = leadership
        self.save = save
    }
}
