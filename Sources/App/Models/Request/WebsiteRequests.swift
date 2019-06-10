import Vapor
import RoasterHammer_Shared

typealias DynamicFormData = [String: [String: String]]

protocol WebContextTitle {
    var title: String { get }
}

protocol AddRuleData {
    var rules: DynamicFormData { get }
}

struct IndexContext: WebContextTitle, Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct UnitsContext: WebContextTitle, Encodable {
    let title: String
    let units: [UnitResponse]
}

struct UnitDetailsContext: Encodable {
    let unit: UnitResponse
    let army: ArmyResponse
    let warlordTraits: [WarlordTraitResponse]
    let isPsycher: Bool
    let psychicPowers: [PsychicPowerResponse]
}

struct CreateArmyContext: WebContextTitle, Encodable {
    let title: String
    let existingRules: [Rule]
}

struct EditArmyContext: WebContextTitle, Encodable {
    let title: String
    let army: ArmyResponse
    let existingRules: [Rule]
    let editing: Bool = true
}

struct CreateArmyAndRulesData: AddRuleData, Content {
    let armyName: String
    let rules: DynamicFormData
    let existingRuleCheckbox: [String: String]
}

struct CreateFactionContext: WebContextTitle, Encodable {
    let title: String
    let army: ArmyResponse
}

struct EditFactionContext: WebContextTitle, Encodable {
    let title: String
    let faction: FactionResponse
    let editing: Bool = true
}

struct CreateFactionAndRulesData: AddRuleData, Content {
    let factionName: String
    let rules: DynamicFormData
}

struct ArmyContext: Encodable {
    let army: ArmyResponse
    let units: [UnitResponse]
}

struct WeaponsContext: WebContextTitle, Encodable {
    let title: String
    let weapons: [Weapon]
}

struct EditWeaponContext: WebContextTitle, Encodable {
    let title: String
    let weapon: Weapon
    let editing: Bool = true
}

struct CreateWeaponContext: WebContextTitle, Encodable {
    let title: String
}

struct CreateWeaponData: Content {
    let name: String
    let range: String
    let type: String
    let strength: String
    let armorPiercing: String
    let damage: String
    let cost: String
    let ability: String
}

struct CreateUnitContext: WebContextTitle, Encodable {
    let title: String
    let army: ArmyResponse
    let unitTypes: [UnitType]
    let existingRules: [Rule]
    let keywords: [Keyword]
}

struct CreateUnitData: Content {
    let unitName: String
    let isUniqueCheckbox: String?
    let unitMinQuantity: String
    let unitMaxQuantity: String
    let unitTypeId: String
    let armyId: String
    let keywords: [String]?
    let models: DynamicFormData
    let rules: DynamicFormData
    let existingRuleCheckbox: [String: String]
}

struct EditUnitContext: WebContextTitle, Encodable {
    let title: String
    let unit: UnitResponse
    let armies: [ArmyResponse]
    let existingRules: [Rule]
    let unitTypes: [UnitType]
    let editing: Bool = true
}

struct WeaponBucketsContext: WebContextTitle, Encodable {
    let title: String
    let model: ModelResponse
}

struct CreateWeaponBucketData: Content {
    let weaponBuckets: DynamicFormData
}

struct EditWeaponBucketContext: WebContextTitle, Encodable {
    let title: String
    let weaponBucket: WeaponBucket
    let weapons: [Weapon]
}

struct EditWeaponBucketData: Content {
    let weaponCheckbox: [String: String]
}

struct RulesContext: WebContextTitle, Encodable {
    let title: String
    let rules: [Rule]
}

struct RuleContext: Encodable {
    let rule: Rule
    let editing: Bool
}

struct EditRuleData: Content {
    let name: String
    let description: String
}

struct RelicContext: Encodable {
    let army: ArmyResponse
}

struct CreateRelicContext: WebContextTitle, Encodable {
    let title: String
    let armyId: Int
    let weapons: [Weapon]
    let keywords: [Keyword]
}

struct CreateRelicData: Content {
    let name: String
    let description: String
    let armyId: Int
    let keywords: [String]?
    let weaponCheckbox: [String: String]
}

struct WarlordTraitContext: Encodable {
    let army: ArmyResponse
}

struct CreateWarlordTraitContext: WebContextTitle, Encodable {
    let title: String
    let armyId: Int
}

struct CreateWarlordTraitData: Content {
    let name: String
    let description: String
    let armyId: Int
}

struct AssignWarlordTraitData: Content {
    let warlordTraitCheckbox: [String: String]
}

struct PsychicPowerContext: Encodable {
    let army: ArmyResponse
}

struct CreatePsychicPowerContext: WebContextTitle, Encodable {
    let title: String
    let armyId: Int
}

struct CreatePsychicPowerData: Content {
    let name: String
    let description: String
    let armyId: Int
}
