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
}

struct CreateArmyContext: WebContextTitle, Encodable {
    let title: String
}

struct EditArmyContext: WebContextTitle, Encodable {
    let title: String
    let army: ArmyResponse
    let editing: Bool = true
}

struct CreateArmyAndRulesData: AddRuleData, Content {
    let armyName: String
    let rules: DynamicFormData
}

struct CreateFactionContext: WebContextTitle, Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct EditFactionContext: WebContextTitle, Encodable {
    let title: String
    let faction: FactionResponse
    let armies: [ArmyResponse]
    let editing: Bool = true
}

struct CreateFactionAndRulesData: AddRuleData, Content {
    let factionName: String
    let armyId: Int
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
    let armies: [ArmyResponse]
    let unitTypes: [UnitType]
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
}

struct EditUnitContext: WebContextTitle, Encodable {
    let title: String
    let unit: UnitResponse
    let armies: [ArmyResponse]
    let unitTypes: [UnitType]
    let editing: Bool = true
}

struct AssignWeaponToUnitContext: WebContextTitle, Encodable {
    let title: String
    let unit: UnitResponse
    let weapons: [Weapon]
}

struct AssignWeaponData: Content {
    let weaponCheckbox: DynamicFormData
    let minQuantitySelection: DynamicFormData
    let maxQuantitySelection: DynamicFormData
}

struct WeaponBucketsContext: WebContextTitle, Encodable {
    let title: String
    let unit: UnitResponse
}

struct CreateWeaponBucketData: Content {
    let weaponBuckets: DynamicFormData
}
