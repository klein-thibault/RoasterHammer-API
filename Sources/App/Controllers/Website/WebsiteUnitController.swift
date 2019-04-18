import Vapor
import Leaf
import RoasterHammer_Shared

struct WebsiteUnitController {

    // MARK: - Public Functions

    func unitsHandler(_ req: Request) throws -> Future<View> {
        return UnitController()
            .getUnits(armyId: nil, unitType: nil, conn: req)
            .flatMap(to: View.self, { units in
                let context = UnitsContext(title: "Units", units: units)
                return try req.view().render("units", context)
            })
    }

    func unitHandler(_ req: Request) throws -> Future<View> {
        let unitId = try req.parameters.next(Int.self)

        return UnitController()
            .getUnit(byID: unitId, conn: req)
            .flatMap(to: View.self, { unit in
                let context = UnitDetailsContext(unit: unit)
                return try req.view().render("unit", context)
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

    func deleteUnitHandler(_ req: Request) throws -> Future<Response> {
        let unitId = try req.parameters.next(Int.self)
        return UnitController()
            .deleteUnit(unitId: unitId, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/units"))
    }

    func assignWeaponHandler(_ req: Request) throws -> Future<View> {
        let unitId = try req.parameters.next(Int.self)
        let unitFuture = UnitController().getUnit(byID: unitId, conn: req)
        let weaponsFuture = WeaponController().getAllWeapons(conn: req)

        return flatMap(to: View.self, unitFuture, weaponsFuture, { (unit, weapons) in
            let context = AssignWeaponToUnitContext(title: "Assign Weapons To Unit",
                                                    unit: unit,
                                                    weapons: weapons)

            return try req.view().render("unitWeapons", context)
        })
    }

    /*
     weaponCheckbox: ["{modelId}": ["{weaponId}}": "on"]],
     minQuantitySelection: ["{modelId}": ["{weaponId}": "1"]],
     maxQuantitySelection: ["{modelId}": ["{weaponId}": "1"]]
     */
    func assignWeaponPostHandler(_ req: Request, assignWeaponRequest: AssignWeaponData) throws -> Future<Response> {
        let unitId = try req.parameters.next(Int.self)
        let weaponController = WeaponController()
        var assignWeaponToUnitFutures: [Future<UnitResponse>] = []

        // Go through each model Id
        for modelId in assignWeaponRequest.minQuantitySelection.keys {
            // Only selected weapons will be in weapon checkbox.
            // If a weapon is missing from weaponCheckbox, it can be ignored since it has not been selected
            // TODO: update with weapon buckets
//            if let modelIdInt = modelId.intValue,
//                let weaponSelection = assignWeaponRequest.weaponCheckbox[modelId],
//                let minQuantitySelection = assignWeaponRequest.minQuantitySelection[modelId],
//                let maxQuantitySelection = assignWeaponRequest.maxQuantitySelection[modelId] {
//                let weaponIds = weaponSelection.keys
//                for weaponId in weaponIds {
//                    if let weaponIdInt = weaponId.intValue,
//                        let minQuantity = minQuantitySelection[weaponId]?.intValue,
//                        let maxQuantity = maxQuantitySelection[weaponId]?.intValue {
//                        let addWeaponToModelRequest = AddWeaponToModelRequest(minQuantity: minQuantity, maxQuantity: maxQuantity)
//
//                        assignWeaponToUnitFutures.append(weaponController.addWeaponToModel(unitId: unitId,
//                                                                                           modelId: modelIdInt,
//                                                                                           weaponId: weaponIdInt,
//                                                                                           request: addWeaponToModelRequest,
//                                                                                           conn: req))
//                    }
//                }
//            }
        }

        return assignWeaponToUnitFutures.flatten(on: req)
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
