import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteUnitController {

    // MARK: - Public Functions

    func unitsHandler(_ req: Request) throws -> Future<View> {
        return UnitDatabaseQueries()
            .getUnits(armyId: nil, unitType: nil, conn: req)
            .flatMap(to: View.self, { units in
                let context = UnitsContext(title: "Units", units: units)
                return try req.view().render("units", context)
            })
    }

    func unitHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)

        let armyFuture = try ArmyController().getArmy(byID: armyId, conn: req)
        let unitFuture = UnitDatabaseQueries().getUnit(byID: unitId, conn: req)

        return flatMap(to: View.self, armyFuture, unitFuture, { (army, unit) in
            let warlordTraits = army.warlordTraits.subtracting(unit.availableWarlordTraits)
            let context = UnitDetailsContext(unit: unit, army: army, warlordTraits: warlordTraits)
            return try req.view().render("unit", context)
        })
    }

    func createUnitHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let armyFuture = try ArmyController().getArmy(byID: armyId, conn: req)
        let unitTypesFuture = UnitTypeController().getAllUnitTypes(conn: req)
        let existingRulesFuture = RuleController().getAllRules(conn: req)
        let keywordsFuture = KeywordController().getAllKeywords(conn: req)

        return flatMap(to: View.self,
                       armyFuture,
                       unitTypesFuture,
                       existingRulesFuture,
                       keywordsFuture) { (army, unitTypes, existingRules, keywords) in
                        let context = CreateUnitContext(title: "Create A Unit",
                                                        army: army,
                                                        unitTypes: unitTypes,
                                                        existingRules: existingRules,
                                                        keywords: keywords)
                        return try req.view().render("createUnit", context)
        }
    }

    func createUnitPostHandler(_ req: Request,
                               createUnitData: CreateUnitData) throws -> Future<Response> {
        let newUnitRequest = try createUnitRequest(forData: createUnitData)
        let existingRuleIds = createUnitData.existingRuleCheckbox.keys.compactMap { $0.intValue }
        let ruleController = RuleController()
        let existingRulesFuture = existingRuleIds.map { return ruleController.getRuleByID($0, conn: req) }.flatten(on: req)

        return existingRulesFuture.flatMap(to: Response.self, { existingRules in
            return UnitDatabaseQueries()
                .createUnit(request: newUnitRequest, conn: req)
                .flatMap(to: [UnitRule].self, { unit in
                    return try self.assignExistingRulesToUnit(unit: unit, rules: existingRules, conn: req)
                })
                .transform(to: req.redirect(to: "/roasterhammer/armies/\(createUnitData.armyId)"))
        })


    }

    func editUnitHandler(_ req: Request) throws -> Future<View> {
        let unitId = try req.parameters.next(Int.self)

        let armiesFuture = try ArmyController().getAllArmies(conn: req)
        let unitTypesFuture = UnitTypeController().getAllUnitTypes(conn: req)
        let unitFuture = UnitDatabaseQueries().getUnit(byID: unitId, conn: req)
        let existingRulesFuture = RuleController().getAllRules(conn: req)

        return flatMap(to: View.self,
                       armiesFuture,
                       unitTypesFuture,
                       existingRulesFuture,
                       unitFuture, { (armies, unitTypes, existingRules, unit) in
                        let filteredRules = existingRules.filter({ existingRule in
                            return !unit.rules.contains(where: { rule in
                                return rule.name == existingRule.name
                                    && rule.description == existingRule.description
                            })
                        })
                        let context = EditUnitContext(title: "Edit Unit",
                                                      unit: unit,
                                                      armies: armies,
                                                      existingRules: filteredRules,
                                                      unitTypes: unitTypes)
                        return try req.view().render("createUnit", context)
        })
    }

    func editUnitPostHandler(_ req: Request, editUnitRequest: CreateUnitData) throws -> Future<Response> {
        let unitId = try req.parameters.next(Int.self)
        let existingRuleIds = editUnitRequest.existingRuleCheckbox.keys.compactMap { $0.intValue }
        let ruleController = RuleController()
        let existingRulesFuture = existingRuleIds.map { return ruleController.getRuleByID($0, conn: req) }.flatten(on: req)

        return existingRulesFuture.flatMap(to: Response.self, { existingRules in
            let editUnitRequest = try self.createUnitRequest(forData: editUnitRequest)
            return UnitDatabaseQueries()
                .editUnit(unitId: unitId, request: editUnitRequest, conn: req)
                .flatMap(to: [UnitRule].self, { unit in
                    return try self.assignExistingRulesToUnit(unit: unit, rules: existingRules, conn: req)
                })
                .transform(to: req.redirect(to: "/roasterhammer/units"))
        })
    }

    func deleteUnitHandler(_ req: Request) throws -> Future<Response> {
        let unitId = try req.parameters.next(Int.self)
        return UnitDatabaseQueries()
            .deleteUnit(unitId: unitId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/units"))
    }

    func warlordTraitsHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)

        let armyFuture = try ArmyController().getArmy(byID: armyId, conn: req)
        let unitFuture = UnitDatabaseQueries().getUnit(byID: unitId, conn: req)

        return flatMap(to: View.self, armyFuture, unitFuture, { (army, unit) in
            let warlordTraits = army.warlordTraits.subtracting(unit.availableWarlordTraits)
            let context = UnitDetailsContext(unit: unit, army: army, warlordTraits: warlordTraits)
            return try req.view().render("unitWarlordTraits", context)
        })
    }

    func warlordTraitsPostHandler(_ req: Request, assignWarlordTraits: AssignWarlordTraitData) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)
        let warlordTraitIds = assignWarlordTraits.warlordTraitCheckbox.keys.compactMap { $0.intValue }

        let unitFuture = Unit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let warlordTraitController = WarlordTraitController()
        let warlordTraitsFuture = warlordTraitIds.map { warlordTraitController.getWarlordById($0, conn: req) }.flatten(on: req)

        return flatMap(to: Response.self, unitFuture, warlordTraitsFuture, { (unit, warlordTraits) in
            return UnitDatabaseQueries()
                .addAvailableWarlordTraitsToUnit(unit, warlordTraits: warlordTraits, conn: req)
                .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)/units/\(unitId)"))
        })
    }

    func deleteWarlordTraitFromUnitHandler(_ req: Request) throws -> Future<Response> {
        let armyId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)
        let warlordTraitId = try req.parameters.next(Int.self)

        let unitFuture = Unit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let warlordTraitFuture = WarlordTraitController().getWarlordById(warlordTraitId, conn: req)

        return flatMap(to: Response.self, unitFuture, warlordTraitFuture, { (unit, warlordTrait) in
            return UnitDatabaseQueries()
                .removeWarlordTraitFromUnit(unit, warlordTrait: warlordTrait, conn: req)
                .transform(to: req.redirect(to: "/roasterhammer/armies/\(armyId)/units/\(unitId)"))
        })
    }

    // MARK: - Private Functions

    private func createUnitRequest(forData data: CreateUnitData) throws -> CreateUnitRequest {
        guard let minQuantity = data.unitMinQuantity.intValue,
            let maxQuantity = data.unitMaxQuantity.intValue,
            let unitTypeId = data.unitTypeId.intValue,
            let armyId = data.armyId.intValue else {
                throw Abort(.badRequest)
        }

        let isUnique = data.isUniqueCheckbox?.isCheckboxOn ?? false
        let keywords: [String] = data.keywords ?? []
        let models = addModelRequest(forModelData: data.models)
        let rules = WebRequestUtils().addRuleRequest(forRuleData: data.rules)

        return CreateUnitRequest(name: data.unitName,
                                 isUnique: isUnique,
                                 minQuantity: minQuantity,
                                 maxQuantity: maxQuantity,
                                 unitTypeId: unitTypeId,
                                 armyId: armyId,
                                 models: models,
                                 keywords: keywords,
                                 rules: rules)
    }

    private func addModelRequest(forModelData modelData: DynamicFormData) -> [CreateModelRequest] {
        var models: [CreateModelRequest] = []
        for modelDictionary in modelData.values {
            if let modelName = modelDictionary["name"], modelName.count > 0,
                let modelCostString = modelDictionary["cost"],
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
                let modelCost = modelCostString.intValue,
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
                                               cost: modelCost,
                                               minQuantity: modelMinQuantity,
                                               maxQuantity: modelMaxQuantity,
                                               weaponQuantity: modelWeaponQuantity,
                                               characteristics: modelCharacteristics)
                models.append(model)
            }
        }

        return models
    }

    private func assignExistingRulesToUnit(unit: Unit, rules: [Rule], conn: DatabaseConnectable) throws -> Future<[UnitRule]> {
        return try rules.map {
            UnitDatabaseQueries().assignRuleToUnit(unitId: try unit.requireID(),
                                                   rule: $0,
                                                   conn: conn)
            }
            .flatten(on: conn)
    }

}
