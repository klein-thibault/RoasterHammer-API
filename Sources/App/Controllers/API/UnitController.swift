import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

final class UnitController {
    
    // MARK: - Public Functions
    
    func createUnit(_ req: Request) throws -> Future<UnitResponse> {
        return try req.content.decode(CreateUnitRequest.self)
            .flatMap(to: Unit.self, { request in
                return self.createUnit(request: request, conn: req)
            })
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitResponse(forUnit: unit, conn: req)
            })
    }
    
    func units(_ req: Request) throws -> Future<[UnitResponse]> {
        let filters = try req.query.decode(UnitFilters.self)
        let armyId: Int? = (filters.armyId != nil) ? filters.armyId!.intValue : nil
        return getUnits(armyId: armyId, unitType: filters.unitType, conn: req)
    }

    func getUnit(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        return getUnit(byID: unitId, conn: req)
    }

    func editUnit(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        return try req.content.decode(CreateUnitRequest.self)
            .flatMap(to: Unit.self, { request in
                return self.editUnit(unitId: unitId, request: request, conn: req)
            })
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitResponse(forUnit: unit, conn: req)
            })
    }

    func deleteUnit(_ req: Request) throws -> Future<HTTPStatus> {
        let unitId = try req.parameters.next(Int.self)
        return deleteUnit(unitId: unitId, conn: req)
    }
    
    func addUnitToDetachmentUnitRole(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let roleId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)

        let roleFuture = Role.find(roleId, on: req).unwrap(or: RoasterHammerError.roleIsMissing.error())
        let unitFuture = Unit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let detachmentFuture = Detachment.find(detachmentId, on: req).unwrap(or: RoasterHammerError.detachmentIsMissing.error())
        let requestFuture = try req.content.decode(AddUnitToDetachmentRequest.self)

        return flatMap(roleFuture,
                       unitFuture,
                       detachmentFuture,
                       requestFuture, { (role, unit, detachment, request) in
                        // Validate if the unit is able to be added for the detachment and role
                        return try self.validateAddingUnitToDetachment(detachment: detachment, role: role, unit: unit, conn: req)
                            .flatMap(to: SelectedUnit.self, { _ in
                                // Create the selected unit
                                return try self.createSelectedUnit(unit: unit,
                                                                   quantity: request.unitQuantity,
                                                                   conn: req)
                            })
                            .flatMap(to: SelectedUnit.self, { selectedUnit in
                                // Create the default models of the selected unit
                                return try self.createInitialModelsForSelectedUnit(unit: unit,
                                                                                   selectedUnit: selectedUnit,
                                                                                   conn: req)
                            })
                            .flatMap({ selectedUnit in
                                // Attach the unit to the detachment's role
                                return role.units.attach(selectedUnit, on: req)
                            })
                            .flatMap(to: DetachmentResponse.self, { _ in
                                // Return the updated detachment
                                let detachmentController = DetachmentController()
                                return try detachmentController.getDetachmentById(detachmentId, conn: req)
                            })
        })
    }

    func removeUnitFromDetachmentUnitRole(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let roleId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)

        let unitFuture = SelectedUnit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let roleFuture = Role.find(roleId, on: req).unwrap(or: RoasterHammerError.roleIsMissing.error())
        let detachmentFuture = Detachment.find(detachmentId, on: req).unwrap(or: RoasterHammerError.detachmentIsMissing.error())

        return flatMap(unitFuture, roleFuture, detachmentFuture, { (unit, role, detachment) in
            return role.units.detach(unit, on: req)
                .flatMap(to: DetachmentResponse.self, { _ in
                    // Return the updated detachment
                    let detachmentController = DetachmentController()
                    return try detachmentController.getDetachmentById(detachmentId, conn: req)
                })
        })
    }

    func addModelToUnit(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)

        let detachmentFuture = Detachment.find(detachmentId, on: req).unwrap(or: RoasterHammerError.detachmentIsMissing.error())
        let unitFuture = SelectedUnit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let modelFuture = Model.find(modelId, on: req).unwrap(or: RoasterHammerError.modelIsMissing.error())

        return flatMap(detachmentFuture, unitFuture, modelFuture, { detachment, unit, model in
            return try self.validateAddingModelInUnit(unit: unit, model: model, conn: req)
                .flatMap(to: SelectedModel.self, { _ in
                    return SelectedModel(modelId: modelId).save(on: req)
                })
                .flatMap({ selectedModel in
                    return unit.models.attach(selectedModel, on: req)
                })
                .flatMap(to: DetachmentResponse.self, { _ in
                    // Return the updated detachment
                    let detachmentController = DetachmentController()
                    return try detachmentController.getDetachmentById(detachmentId, conn: req)
                })
        })
    }

    func removeModelFromUnit(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)

        let unitFuture = SelectedUnit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing.error())
        let modelFuture = SelectedModel.find(modelId, on: req).unwrap(or: RoasterHammerError.modelIsMissing.error())

        return flatMap(to: DetachmentResponse.self, unitFuture, modelFuture, { (unit, model) in
            return try self.validateRemovingModelFromUnit(unit: unit, model: model, conn: req)
                .flatMap({ _ in
                    return unit.models.detach(model, on: req)
                })
                .flatMap(to: DetachmentResponse.self, { _ in
                    let detachmentController = DetachmentController()
                    return try detachmentController.getDetachmentById(detachmentId, conn: req)
                })
        })
    }

    func attachWeaponToSelectedModel(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)
        let weaponBucketId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)

        let selectedModelFuture = SelectedModel.find(modelId, on: req).unwrap(or: RoasterHammerError.modelIsMissing.error())
        let weaponBucketFuture = WeaponBucketController().getWeaponBucket(byID: weaponBucketId, conn: req)
        let weaponFuture = WeaponController().getWeapon(byID: weaponId, conn: req)

        return flatMap(selectedModelFuture, weaponBucketFuture, weaponFuture, { (selectedModel, weaponBucket, weapon) in
            return try self.validateWeaponsForSelectedModel(selectedModel: selectedModel,
                                                            weaponBucket: weaponBucket,
                                                            conn: req)
                .flatMap(to: SelectedModelWeapon.self, { _ in
                    return try SelectedModelWeapon(modelId: selectedModel.requireID(),
                                                   weaponBucketId: weaponBucket.requireID(),
                                                   weaponId: weapon.requireID())
                    .save(on: req)
                })
                .flatMap(to: Detachment.self, { _ in
                    return Detachment.find(detachmentId, on: req)
                        .unwrap(or: RoasterHammerError.detachmentIsMissing.error())
                })
                .flatMap(to: DetachmentResponse.self, { detachment in
                    let detachmentController = DetachmentController()
                    return try detachmentController.getDetachmentById(detachmentId, conn: req)
                })
        })
    }
    
    // MARK: - Utility Functions

    func getUnits(armyId: Int?,
                  unitType: String?,
                  conn: DatabaseConnectable) -> Future<[UnitResponse]> {
        func performGetUnitQuery(unitQuery: EventLoopFuture<[Unit]>) -> Future<[UnitResponse]> {
            return unitQuery.flatMap(to: [UnitResponse].self, { units in
                return try units
                    .map { try self.unitResponse(forUnit: $0, conn: conn) }
                    .flatten(on: conn)
            })
        }

        let unitQuery: EventLoopFuture<[Unit]>
        Unit.query(on: conn).filter(\.unitTypeId == 1)

        if let unitType = unitType {
            return UnitType.query(on: conn)
                .filter(\.name == unitType)
                .first()
                .unwrap(or: RoasterHammerError.unitTypeIsMissing.error())
                .flatMap(to: [UnitResponse].self, { unitType in
                    let unitQuery: EventLoopFuture<[Unit]>
                    let unitTypeId = try unitType.requireID()

                    if let armyId = armyId {
                        unitQuery = Unit.query(on: conn).filter(\.armyId == armyId).filter(\.unitTypeId == unitTypeId).all()
                    } else {
                        unitQuery = Unit.query(on: conn).filter(\.unitTypeId == unitTypeId).all()
                    }

                    return performGetUnitQuery(unitQuery: unitQuery)
                })
        } else {
            if let armyId = armyId {
                unitQuery = Unit.query(on: conn).filter(\.armyId == armyId).all()
            } else {
                unitQuery = Unit.query(on: conn).all()
            }

            return performGetUnitQuery(unitQuery: unitQuery)
        }
    }

    func getUnit(byID id: Int, conn: DatabaseConnectable) -> Future<UnitResponse> {
        return Unit.find(id, on: conn)
            .unwrap(or: RoasterHammerError.unitIsMissing.error())
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitResponse(forUnit: unit, conn: conn)
            })
    }

    func getModel(byID id: Int, conn: DatabaseConnectable) -> Future<Model> {
        return Model.find(id, on: conn)
        .unwrap(or: RoasterHammerError.modelIsMissing.error())
    }

    func selectedModelResponse(forSelectedModel selectedModel: SelectedModel,
                               conn: DatabaseConnectable) throws -> Future<SelectedModelResponse> {
        let modelFuture = Model
            .find(selectedModel.modelId, on: conn)
            .unwrap(or: RoasterHammerError.modelIsMissing.error())
        let modelResponseFuture = Model
            .find(selectedModel.modelId, on: conn)
            .unwrap(or: RoasterHammerError.modelIsMissing.error())
            .flatMap(to: ModelResponse.self) { model in
                return try self.modelResponse(forModel: model, conn: conn)
        }
        let selectedWeaponsFuture = try selectedWeaponsForSelectedModel(selectedModel, conn: conn)

        return flatMap(to: SelectedModelResponse.self,
                       modelFuture,
                       modelResponseFuture,
                       selectedWeaponsFuture, { model, modelResponse, selectedWeapons in
                        let weaponController = WeaponController()

                        return selectedWeapons
                            .map { weaponController.getWeapon(byID: $0.weaponId, conn: conn) }.flatten(on: conn)
                            .map({ weapons in
                                let weaponResponses = try weapons.map { try weaponController.weaponResponse(forWeapon: $0) }
                                let selectedModelDTO = SelectedModelDTO(id: try selectedModel.requireID())
                                return SelectedModelResponse(selectedModel: selectedModelDTO,
                                                             model: modelResponse,
                                                             selectedWeapons: weaponResponses)
                            })
        })
    }
    
    func selectedUnitResponse(forSelectedUnit selectedUnit: SelectedUnit,
                              conn: DatabaseConnectable) throws -> Future<SelectedUnitResponse> {
        let unitFuture = Unit
            .find(selectedUnit.unitId, on: conn)
            .unwrap(or: RoasterHammerError.unitIsMissing.error())
            .flatMap(to: UnitResponse.self) { (unit) in
                return try self.unitResponse(forUnit: unit, conn: conn)
        }
        let selectedModels = try selectedUnit.models.query(on: conn).all()
        
        return flatMap(unitFuture,
                       selectedModels, { (unit, selectedModels) in
                        return try selectedModels.map { try self.selectedModelResponse(forSelectedModel: $0,
                                                                                       conn: conn) }
                            .flatten(on: conn)
                            .map(to: SelectedUnitResponse.self, { selectedModels in
                                // Sorted by models with lower max quantity to have sergeants etc on top
                                let sortedSelectedModels = selectedModels.sorted(by: { $0.model.maxQuantity < $1.model.maxQuantity })
                                let selectedUnitDTO = SelectedUnitDTO(id: try selectedUnit.requireID())
                                return SelectedUnitResponse(selectedUnit: selectedUnitDTO,
                                                            unit: unit,
                                                            models: sortedSelectedModels)
                            })
        })
    }
    
    func unitResponse(forUnit unit: Unit, conn: DatabaseConnectable) throws -> Future<UnitResponse> {
        let unitModelsFuture = try unit.models.query(on: conn).all()
        let unitKeywordsFuture = try unit.keywords.query(on: conn).all()
        let unitTypeFuture = unit.unitType.get(on: conn)
        let unitRulesFuture = try unit.rules.query(on: conn).all()
        let armyController = ArmyController()
        let unitArmyFuture = try armyController.getArmy(byID: unit.armyId, conn: conn)

        return flatMap(to: UnitResponse.self,
                       unitModelsFuture,
                       unitKeywordsFuture,
                       unitTypeFuture,
                       unitRulesFuture,
                       unitArmyFuture) { (models, keywords, unitType, rules, army) in
                        return try models
                            .map { try self.modelResponse(forModel: $0, conn: conn) }
                            .flatten(on: conn)
                            .map(to: UnitResponse.self, { modelResponses in
                                let keywordStrings = keywords.map { $0.name }
                                let unitTypeString = unitType.name
                                let unitDTO = UnitDTO(id: try unit.requireID(),
                                                      name: unit.name,
                                                      isUnique: unit.isUnique,
                                                      minQuantity: unit.minQuantity,
                                                      maxQuantity: unit.maxQuantity)
                                let rulesResponse = RuleController().rulesResponse(forRules: rules)
                                return UnitResponse(unit: unitDTO,
                                                    unitType: unitTypeString,
                                                    army: army,
                                                    models: modelResponses,
                                                    keywords: keywordStrings,
                                                    rules: rulesResponse)
                            })
        }
    }

    func modelResponse(forModel model: Model, conn: DatabaseConnectable) throws -> Future<ModelResponse> {
        let characteristicsFuture = try model.characteristics.query(on: conn).first().unwrap(or: RoasterHammerError.characteristicsAreMissing.error())
        let weaponBucketsFuture = try model.weaponBuckets.query(on: conn).all()

        return flatMap(to: ModelResponse.self,
                       characteristicsFuture,
                       weaponBucketsFuture, { (characteristics, weaponBuckets) in
                        let weaponBucketController = WeaponBucketController()
                        return try weaponBuckets
                            .map { try weaponBucketController.weaponBucketResponse(forWeaponBucket: $0, conn: conn) }
                            .flatten(on: conn)
                            .map(to: ModelResponse.self, { (weaponBucketResponses) in
                                let modelDTO = ModelDTO(id: try model.requireID(),
                                                        name: model.name,
                                                        cost: model.cost,
                                                        minQuantity: model.minQuantity,
                                                        maxQuantity: model.maxQuantity,
                                                        weaponQuantity: model.weaponQuantity)
                                let characteristicsDTO = CharacteristicsDTO(id: try characteristics.requireID(),
                                                                            movement: characteristics.movement,
                                                                            weaponSkill: characteristics.weaponSkill,
                                                                            balisticSkill: characteristics.balisticSkill,
                                                                            strength: characteristics.strength,
                                                                            toughness: characteristics.toughness,
                                                                            wounds: characteristics.wounds,
                                                                            attacks: characteristics.attacks,
                                                                            leadership: characteristics.leadership,
                                                                            save: characteristics.save,
                                                                            modelId: characteristics.modelId)
                                return ModelResponse(model: modelDTO,
                                                     characteristics: characteristicsDTO,
                                                     weaponBuckets: weaponBucketResponses)
                            })
        })
    }

    func createUnit(request: CreateUnitRequest, conn: DatabaseConnectable) -> Future<Unit> {
        return Unit(name: request.name,
                    isUnique: request.isUnique,
                    minQuantity: request.minQuantity,
                    maxQuantity: request.maxQuantity,
                    unitTypeId: request.unitTypeId,
                    armyId: request.armyId)
            .save(on: conn)
            .flatMap(to: Unit.self, { unit in
                return try self.createModels(forUnit: unit,
                                             request: request.models,
                                             conn: conn)
            })
            .flatMap(to: Unit.self, { unit in
                return self.createKeywords(forUnit: unit,
                                           keywords: request.keywords,
                                           conn: conn)
            })
            .flatMap(to: Unit.self, { unit in
                return self.createRules(forUnit: unit,
                                        rules: request.rules,
                                        conn: conn)
            })
    }

    func editUnit(unitId: Int, request: CreateUnitRequest, conn: DatabaseConnectable) -> Future<Unit> {
        return Unit.find(unitId, on: conn)
            .unwrap(or: RoasterHammerError.unitIsMissing.error())
            .flatMap(to: Unit.self, { unit in
                unit.name = request.name
                unit.isUnique = request.isUnique
                unit.minQuantity = request.minQuantity
                unit.maxQuantity = request.maxQuantity
                unit.unitTypeId = request.unitTypeId
                unit.armyId = request.armyId

                return unit.save(on: conn)
            })
            .flatMap(to: Unit.self, { unit in
                return self.editRules(forUnit: unit,
                                      updatedRules: request.rules,
                                      conn: conn)
            })
            .flatMap(to: Unit.self, { unit in
                return self.editKeywords(forUnit: unit,
                                         updatedKeywords: request.keywords,
                                         conn: conn)
            })
            .flatMap(to: Unit.self, { unit in
                return self.editModels(forUnit: unit,
                                       updatedModels: request.models,
                                       conn: conn)
            })
    }

    func deleteUnit(unitId: Int, conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return Unit.find(unitId, on: conn)
            .unwrap(or: RoasterHammerError.unitIsMissing.error())
            .flatMap(to: Unit.self, { unit in
                return try unit.models.query(on: conn).all()
                    .flatMap(to: Unit.self, { (models) -> EventLoopFuture<Unit> in
                        return models.map { $0.delete(on: conn) }
                            .flatten(on: conn)
                            .map(to: Unit.self, { _ in
                                return unit
                            })
                    })
            })
            .flatMap({ unit in
                return unit.delete(on: conn)
            })
            .transform(to: .ok)
    }

    // MARK: - Private Functions

    private func createModels(forUnit unit: Unit,
                              request: [CreateModelRequest],
                              conn: DatabaseConnectable) throws -> Future<Unit> {
        return try request
            .map { try self.createModel(forUnit: unit, request: $0, conn: conn) }
            .flatten(on: conn)
            .map(to: Unit.self, { _ in
                return unit
            })
    }

    private func createModel(forUnit unit: Unit,
                             request: CreateModelRequest,
                             conn: DatabaseConnectable) throws -> Future<Unit> {
        return Model(name: request.name,
                     cost: request.cost,
                     minQuantity: request.minQuantity,
                     maxQuantity: request.maxQuantity,
                     weaponQuantity: request.weaponQuantity)
            .save(on: conn)
            .flatMap(to: Model.self, { model in
                return unit.models.attach(model, on: conn)
                    .map(to: Model.self, { _ in
                        return model
                    })
            })
            .flatMap(to: Characteristics.self, { model in
                return try self.createCharacteristics(forModel: model,
                                                      characteristics: request.characteristics,
                                                      conn: conn)
            })
            .map(to: Unit.self, { _ in
                return unit
            })
    }

    private func createCharacteristics(forModel model: Model,
                                       characteristics: CreateCharacteristicsRequest,
                                       conn: DatabaseConnectable) throws -> Future<Characteristics> {
        let modelId = try model.requireID()
        return Characteristics(movement: characteristics.movement,
                               weaponSkill: characteristics.weaponSkill,
                               balisticSkill: characteristics.balisticSkill,
                               strength: characteristics.strength,
                               toughness: characteristics.toughness,
                               wounds: characteristics.wounds,
                               attacks: characteristics.attacks,
                               leadership: characteristics.leadership,
                               save: characteristics.save,
                               modelId: modelId)
            .save(on: conn)
    }

    private func createKeywords(forUnit unit: Unit,
                                keywords: [KeywordName],
                                conn: DatabaseConnectable) -> Future<Unit> {
        let keywordsFuture = keywords.map { Keyword(name: $0).save(on: conn) }.flatten(on: conn)
        return keywordsFuture
            .flatMap(to: [UnitKeyword].self) { keywords in
                return keywords.map { unit.keywords.attach($0, on: conn) }.flatten(on: conn)
            }
            .map(to: Unit.self, { _ in
                return unit
            })
    }

    private func createRules(forUnit unit: Unit,
                             rules: [AddRuleRequest],
                             conn: DatabaseConnectable) -> Future<Unit> {
        let rulesFuture = rules
            .map { Rule(name: $0.name, description: $0.description).save(on: conn) }
            .flatten(on: conn)
        return rulesFuture
            .flatMap(to: [UnitRule].self, { rules in
                return rules.map { unit.rules.attach($0, on: conn) }.flatten(on: conn)
            })
            .map(to: Unit.self, { _ in
                return unit
            })
    }

    private func editModels(forUnit unit: Unit,
                            updatedModels: [CreateModelRequest],
                            conn: DatabaseConnectable) -> Future<Unit> {
        return unit.models
            .detachAll(on: conn)
            .flatMap(to: Unit.self, { _ in
                return try self.createModels(forUnit: unit,
                                             request: updatedModels,
                                             conn: conn)
            })
    }

    private func editKeywords(forUnit unit: Unit,
                              updatedKeywords: [KeywordName],
                              conn: DatabaseConnectable) -> Future<Unit> {
        return unit.keywords
            .detachAll(on: conn)
            .flatMap(to: Unit.self, { _ in
                return self.createKeywords(forUnit: unit,
                                           keywords: updatedKeywords,
                                           conn: conn)
            })
    }

    private func editRules(forUnit unit: Unit,
                           updatedRules: [AddRuleRequest],
                           conn: DatabaseConnectable) -> Future<Unit> {
        return unit.rules
            .detachAll(on: conn)
            .flatMap(to: Unit.self, { _ in
                return self.createRules(forUnit: unit,
                                        rules: updatedRules,
                                        conn: conn)
            })
    }

    private func validateAddingUnitToDetachment(detachment: Detachment,
                                                role: Role,
                                                unit: Unit,
                                                conn: DatabaseConnectable) throws -> Future<Void> {
        let roleUnitsFuture = try role.units.query(on: conn).all()
        let unitTypeFuture = unit.unitType.get(on: conn)

        return map(roleUnitsFuture, unitTypeFuture, { (roleUnits, unitType) in
            let isUnitCompatibleForRole = unitType.name == role.name
            let detachmentController = DetachmentController()
            let maxUnitsForRole = detachmentController.minMaxUnits(forDetachment: detachment, andRole: role).max
            let isDetachmentMaxedOut = roleUnits.count >= maxUnitsForRole

            if roleUnits.filter({ $0.unitId == unit.id }).first != nil && unit.isUnique {
                throw RoasterHammerError.addingUniqueUnitMoreThanOnce.error()
            }
            if !isUnitCompatibleForRole {
                throw RoasterHammerError.addingUnitToWrongRole.error()
            }
            if isDetachmentMaxedOut {
                throw RoasterHammerError.tooManyUnitsInDetachment.error()
            }
        })
    }

    private func validateAddingModelInUnit(unit: SelectedUnit, model: Model, conn: DatabaseConnectable) throws -> Future<Void> {
        // Get all selected models for the unit
        return try unit.models.query(on: conn).all()
            .flatMap({ selectedModels in
                // Get the selected model response associated to each to get more information about the selected model
                let selectedModelResponseFutures = try selectedModels.map { try self.selectedModelResponse(forSelectedModel: $0, conn: conn) }
                return selectedModelResponseFutures
                    .flatten(on: conn)
                    .map({ selectedModelResponses in
                        // Filter the already selected models matching the newly added model
                        // If the max quantity is already reached for the selected models in the unit, do not allow an additional model to the unit
                        if let modelMatchingAddedModel = selectedModelResponses.filter({ $0.model.id == model.id! }).first,
                            selectedModels.count >= modelMatchingAddedModel.model.maxQuantity {
                            throw RoasterHammerError.tooManyModelsInUnit.error()
                        }
                    })
            })

    }

    private func validateRemovingModelFromUnit(unit: SelectedUnit,
                                               model: SelectedModel,
                                               conn: DatabaseConnectable) throws -> Future<Void> {
        // Get all selected models for the unit
        return try unit.models.query(on: conn).all()
            .flatMap({ selectedModels in
                // Get the selected model response associated to each to get more information about the selected model
                let selectedModelResponseFutures = try selectedModels.map { try self.selectedModelResponse(forSelectedModel: $0, conn: conn) }
                return selectedModelResponseFutures
                    .flatten(on: conn)
                    .map({ selectedModelResponses in
                        // Filter the already selected models matching the newly added model
                        // If the number of selected models minus the future deletion is lower than the model min quantity,
                        // do not allow removing a model to the unit
                        if let modelMatchingAddedModel = selectedModelResponses.filter({ $0.id == model.id! }).first,
                            selectedModels.count - 1 < modelMatchingAddedModel.model.minQuantity {
                            throw RoasterHammerError.tooFewModelsInUnit.error()
                        }
                    })
            })
    }

    private func validateWeaponsForSelectedModel(selectedModel: SelectedModel,
                                                 weaponBucket: WeaponBucket,
                                                 conn: DatabaseConnectable) throws -> Future<Void> {
        let weaponBucketId = try weaponBucket.requireID()
        let modelFuture = Model.find(selectedModel.modelId, on: conn).unwrap(or: RoasterHammerError.modelIsMissing.error())
        let attachedWeaponsFuture = try selectedWeaponsForSelectedModel(selectedModel, conn: conn)
        let weaponBucketWeaponsFuture = try weaponBucket.weapons.query(on: conn).all()

        return map(modelFuture, attachedWeaponsFuture, weaponBucketWeaponsFuture) { model, attachedWeapons, weaponBucketWeapons in
            if attachedWeapons.count >= model.weaponQuantity {
                throw RoasterHammerError.tooManyWeaponsForModel.error()
            }

            let alreadyAttachedWeaponsFromWeaponBucket = attachedWeapons.filter { $0.weaponBucketId == weaponBucketId }
            if alreadyAttachedWeaponsFromWeaponBucket.count + 1 > weaponBucket.maxWeaponQuantity {
                throw RoasterHammerError.tooManyWeaponSelectionFromWeaponBucket.error()
            }
        }
    }

    private func createSelectedUnit(unit: Unit, quantity: Int, conn: DatabaseConnectable) throws -> Future<SelectedUnit> {
        return try SelectedUnit(unitId: unit.requireID(), quantity: quantity).save(on: conn)
    }

    private func createSelectedModel(model: Model, conn: DatabaseConnectable) throws -> Future<SelectedModel> {
        return try SelectedModel(modelId: model.requireID()).save(on: conn)
    }

    private func attachSelectedModel(_ selectedModel: SelectedModel,
                                     toSelectedUnit selectedUnit: SelectedUnit,
                                     conn: DatabaseConnectable) -> Future<SelectedUnitModel> {
        return selectedUnit.models.attach(selectedModel, on: conn)
    }

    private func createInitialModelsForSelectedUnit(unit: Unit,
                                                    selectedUnit: SelectedUnit,
                                                    conn: DatabaseConnectable) throws -> Future<SelectedUnit> {
        // Get all the models associated with the unit
        return try unit.models.query(on: conn).all()
            // Create all the models that come stock with the selected unit using the min quantity
            .flatMap(to: [SelectedModel].self, { models in
                var selectedModelFutures = [Future<SelectedModel>]()
                for model in models {
                    for _ in 1...model.minQuantity {
                        let createModelFuture = try self.createSelectedModel(model: model, conn: conn)
                        selectedModelFutures.append(createModelFuture)
                    }
                }

                return selectedModelFutures.flatten(on: conn)
            })
            .flatMap(to: [SelectedUnitModel].self, { selectedModels in
                // Attach all the newly created models to the selected unit
                return selectedModels
                    .map { self.attachSelectedModel($0, toSelectedUnit: selectedUnit, conn: conn) }
                    .flatten(on: conn)
            })
            .map(to: SelectedUnit.self, { _ in
                return selectedUnit
            })
    }

    private func selectedWeaponsForSelectedModel(_ selectedModel: SelectedModel,
                                                 conn: DatabaseConnectable) throws -> Future<[SelectedModelWeapon]> {
        return try SelectedModelWeapon.query(on: conn).filter(\.modelId == selectedModel.requireID()).all()
    }

}
