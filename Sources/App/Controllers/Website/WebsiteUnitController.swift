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
                               createUnitData: CreateUnitData) throws -> Future<Response> {
        let newUnitRequest = try createUnitRequest(forData: createUnitData)

        return UnitController()
            .createUnit(request: newUnitRequest, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/units"))
    }

    func editUnitHandler(_ req: Request) throws -> Future<View> {
        let unitId = try req.parameters.next(Int.self)

        let armiesFuture = try ArmyController().getAllArmies(conn: req)
        let unitTypesFuture = UnitTypeController().getAllUnitTypes(conn: req)
        let unitFuture = UnitController().getUnit(byID: unitId, conn: req)

        return flatMap(to: View.self,
                       armiesFuture,
                       unitTypesFuture,
                       unitFuture, { (armies, unitTypes, unit) in
                        let context = EditUnitContext(title: "Edit Unit",
                                                      unit: unit,
                                                      armies: armies,
                                                      unitTypes: unitTypes)
                        return try req.view().render("createUnit", context)
        })
    }

    func editUnitPostHandler(_ req: Request, editUnitRequest: CreateUnitData) throws -> Future<Response> {
        let unitId = try req.parameters.next(Int.self)
        let editUnitRequest = try createUnitRequest(forData: editUnitRequest)
        return UnitController()
            .editUnit(unitId: unitId, request: editUnitRequest, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/units"))
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

}
