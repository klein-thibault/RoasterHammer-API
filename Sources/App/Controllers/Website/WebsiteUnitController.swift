import Vapor
import Leaf

struct WebsiteUnitController {

    // MARK: - Public Functions

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
        let rules = WebRequestUtils().addRuleRequest(forRuleData: createUnitRequest.rules)

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

    // MARK: - Private Functions

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
