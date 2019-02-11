import Vapor
import Leaf

struct WebsiteController {

    func indexHandler(_ req: Request) throws -> Future<View> {
        return try ArmyController().armies(req).flatMap(to: View.self, { armies in
            let context = IndexContext(title: "Homepage", armies: armies)
            return try req.view().render("index", context)
        })
    }

    func unitsHandler(_ req: Request) throws -> Future<View> {
        return UnitController()
            .getUnits(armyId: nil, conn: req)
            .flatMap(to: View.self, { units in
                let context = UnitsContext(title: "Units", units: units)
                return try req.view().render("units", context)
            })
    }

    func createUnitHandler(_ req: Request) throws -> Future<View> {
        let armiesFuture = try ArmyController().getAllArmies(conn: req)
        let unitTypesFuture = UnitTypeController().getAllUnitTypes(conn: req)

        return flatMap(to: View.self, armiesFuture, unitTypesFuture) { (armies, unitTypes) in
            let context = CreateUnitContext(title: "Create A Unit", armies: armies, unitTypes: unitTypes)
            return try req.view().render("createUnit", context)
        }
    }

    func createUnitPostHandler(_ req: Request,
                               createUnitRequest: CreateUnitData) throws -> Future<Response> {
        guard let cost = createUnitRequest.unitCost.intValue,
            let minQuantity = createUnitRequest.unitMinQuantity.intValue,
            let maxQuantity = createUnitRequest.unitMaxQuantity.intValue,
            let unitTypeId = createUnitRequest.unitTypeId.intValue,
            let armyId = createUnitRequest.armyId.intValue else {
                throw Abort(.badRequest)
        }

        let isUnique = createUnitRequest.isUniqueCheckbox?.isCheckboxOn ?? false
        let keywords: [String] = createUnitRequest.keywords ?? []
        let models = addModelRequest(forModelData: createUnitRequest.models)
        let rules = addRuleRequest(forRuleData: createUnitRequest.rules)

        let newUnitRequest = CreateUnitRequest(name: createUnitRequest.unitName,
                                               cost: Int(cost),
                                               isUnique: isUnique,
                                               minQuantity: Int(minQuantity),
                                               maxQuantity: Int(maxQuantity),
                                               unitTypeId: Int(unitTypeId),
                                               armyId: Int(armyId),
                                               models: models,
                                               keywords: keywords,
                                               rules: rules)

        return UnitController()
            .createUnit(request: newUnitRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer/units")
            })
    }

    func weaponsHandler(_ req: Request) throws -> Future<View> {
        return WeaponController()
            .getAllWeapons(conn: req)
            .flatMap(to: View.self, { weapons in
                let context = WeaponsContext(title: "Weapons", weapons: weapons)
                return try req.view().render("weapons", context)
            })
    }

    func createWeaponHandler(_ req: Request) throws -> Future<View> {
        let context = CreateWeaponContext(title: "Create A Weapon")
        return try req.view().render("createWeapon", context)
    }

    func createWeaponPostHandler(_ req: Request,
                                 createWeaponRequest: CreateWeaponData) throws -> Future<Response> {
        let cost = createWeaponRequest.cost.intValue ?? 0
        let newWeaponRequest = CreateWeaponRequest(name: createWeaponRequest.name,
                                                   range: createWeaponRequest.range,
                                                   type: createWeaponRequest.type,
                                                   strength: createWeaponRequest.strength,
                                                   armorPiercing: createWeaponRequest.armorPiercing,
                                                   damage: createWeaponRequest.damage,
                                                   cost: cost,
                                                   ability: createWeaponRequest.ability)

        return WeaponController()
            .createWeapon(request: newWeaponRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer/weapons")
            })
    }

    func armyHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return try ArmyController()
            .getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = ArmyContext(army: army)
                return try req.view().render("army", context)
            })
    }

    func createArmyHandler(_ req: Request) throws -> Future<View> {
        let context = CreateArmyContext(title: "Create An Army")
        return try req.view().render("createArmy", context)
    }

    func createArmyPostHandler(_ req: Request, createArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        let rules = addRuleRequest(forRuleData: createArmyRequest.rules)
        let newArmyRequest = CreateArmyRequest(name: createArmyRequest.armyName,
                                               rules: rules)

        return ArmyController()
            .createArmy(request: newArmyRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

    func createFactionHandler(_ req: Request) throws -> Future<View> {
        return try ArmyController().armies(req).flatMap(to: View.self, { armies in
            let context = CreateFactionContext(title: "Create A Faction", armies: armies)
            return try req.view().render("createFaction", context)
        })
    }

    func createFactionPostHandler(_ req: Request, createFactionRequest: CreateFactionAndRulesData) throws -> Future<Response> {
        let rules = addRuleRequest(forRuleData: createFactionRequest.rules)
        let newFactionRequest = CreateFactionRequest(name: createFactionRequest.factionName, rules: rules)

        return FactionController()
            .createFaction(armyId: createFactionRequest.armyId,
                           request: newFactionRequest,
                           conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

    // MARK: - Private Functions

    private func addRuleRequest(forRuleData ruleData: DynamicFormData) -> [AddRuleRequest] {
        var rules: [AddRuleRequest] = []
        for ruleDictionary in ruleData.values {
            if let ruleName = ruleDictionary["name"], ruleName.count > 0,
                let ruleDescription = ruleDictionary["description"], ruleDescription.count > 0 {
                let rule = AddRuleRequest(name: ruleName,
                                          description: ruleDescription)
                rules.append(rule)
            }
        }

        return rules
    }

    private func addModelRequest(forModelData modelData: DynamicFormData) -> [CreateModelRequest] {
        var models: [CreateModelRequest] = []
        for modelDictionary in modelData.values {
            if let modelName = modelDictionary["name"], modelName.count > 0,
                let modelMinQuantityString = modelDictionary["minQuantity"],
                let modelMaxQuantityString = modelDictionary["maxQuantity"],
                let modelWeaponQuantityString = modelDictionary["weaponQuantity"],
                let modelMovement = modelDictionary["movement"],
                let modelWeaponSkill = modelDictionary["weaponSkill"],
                let modelBalisticSkill = modelDictionary["balisticSkill"],
                let modelStrength = modelDictionary["strength"],
                let modelToughness = modelDictionary["toughness"],
                let modelWounds = modelDictionary["wounds"],
                let modelAttacks = modelDictionary["attacks"],
                let modelLeadership = modelDictionary["leadership"],
                let modelSave = modelDictionary["save"],
                let modelMinQuantity = modelMinQuantityString.intValue,
                let modelMaxQuantity = modelMaxQuantityString.intValue,
                let modelWeaponQuantity = modelWeaponQuantityString.intValue {
                let modelCharacteristics = CreateCharacteristicsRequest(movement: modelMovement,
                                                                        weaponSkill: modelWeaponSkill,
                                                                        balisticSkill: modelBalisticSkill,
                                                                        strength: modelStrength,
                                                                        toughness: modelToughness,
                                                                        wounds: modelWounds,
                                                                        attacks: modelAttacks,
                                                                        leadership: modelLeadership,
                                                                        save: modelSave)
                let model = CreateModelRequest(name: modelName,
                                               minQuantity: modelMinQuantity,
                                               maxQuantity: modelMaxQuantity,
                                               weaponQuantity: modelWeaponQuantity,
                                               characteristics: modelCharacteristics)
                models.append(model)
            }
        }

        return models
    }

}

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

struct CreateArmyContext: WebContextTitle, Encodable {
    let title: String
}

struct CreateArmyAndRulesData: AddRuleData, Content {
    let armyName: String
    let rules: DynamicFormData
}

struct CreateFactionContext: WebContextTitle, Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct CreateFactionAndRulesData: AddRuleData, Content {
    let factionName: String
    let armyId: Int
    let rules: DynamicFormData
}

struct ArmyContext: Encodable {
    let army: ArmyResponse
}

struct WeaponsContext: Encodable {
    let title: String
    let weapons: [Weapon]
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
    let unitCost: String
    let isUniqueCheckbox: String?
    let unitMinQuantity: String
    let unitMaxQuantity: String
    let unitTypeId: String
    let armyId: String
    let keywords: [String]?
    let models: DynamicFormData
    let rules: DynamicFormData
}
