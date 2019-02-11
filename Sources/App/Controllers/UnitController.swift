import Vapor
import FluentPostgreSQL

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
        return getUnits(armyId: filters.armyId, conn: req)
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
                        return try self.validateUnitInDetachment(detachment: detachment, role: role, unit: unit, conn: req)
                            .flatMap(to: SelectedUnit.self, { _ in
                                return try SelectedUnit(unitId: unit.requireID(),
                                                        quantity: request.unitQuantity)
                                    .save(on: req)
                            })
                            .flatMap(to: SelectedUnit.self, { selectedUnit in
                                return try unit.models.query(on: req).all()
                                    .flatMap(to: [SelectedModel].self, { models in
                                        return try models
                                            .map {
                                                try SelectedModel(modelId: $0.requireID(),
                                                                  quantity: $0.minQuantity)
                                                    .save(on: req)
                                            }
                                            .flatten(on: req)
                                    })
                                    .flatMap(to: [SelectedUnitModel].self, { selectedModels in
                                        return selectedModels
                                            .map { selectedUnit.models.attach($0, on: req) }
                                            .flatten(on: req)
                                    })
                                    .map(to: SelectedUnit.self, { _ in
                                        return selectedUnit
                                    })
                            })
                            .flatMap({ selectedUnit in
                                return role.units.attach(selectedUnit, on: req)
                            })
                            .flatMap(to: DetachmentResponse.self, { _ in
                                let detachmentController = DetachmentController()
                                return try detachmentController.detachmentResponse(forDetachment: detachment, conn: req)
                            })
        })
    }
    
    func attachWeaponToSelectedModel(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)
        
        let selectedModelFuture = SelectedModel.find(modelId, on: req).unwrap(or: RoasterHammerError.modelIsMissing.error())
        let weaponFuture = Weapon.find(weaponId, on: req).unwrap(or: RoasterHammerError.weaponIsMissing.error())

        return flatMap(selectedModelFuture, weaponFuture, { (selectedModel, weapon) in
            return try self.validateWeaponsForSelectedModel(selectedModel: selectedModel, conn: req)
                .flatMap({ _ in
                    selectedModel.weapons.attach(weapon, on: req).save(on: req)
                })
                .flatMap(to: Detachment.self, { _ in
                    return Detachment.find(detachmentId, on: req)
                        .unwrap(or: RoasterHammerError.detachmentIsMissing.error())
                })
                .flatMap(to: DetachmentResponse.self, { detachment in
                    let detachmentController = DetachmentController()
                    return try detachmentController.detachmentResponse(forDetachment: detachment, conn: req)
                })
        })
    }
    
    // MARK: - Utility Functions

    func getUnits(armyId: Int?, conn: DatabaseConnectable) -> Future<[UnitResponse]> {
        let unitQuery: EventLoopFuture<[Unit]>
        if let armyId = armyId {
            unitQuery = Unit.query(on: conn).filter(\.armyId == armyId).all()
        } else {
            unitQuery = Unit.query(on: conn).all()
        }

        return unitQuery.flatMap(to: [UnitResponse].self, { units in
            return try units
                .map { try self.unitResponse(forUnit: $0, conn: conn) }
                .flatten(on: conn)
        })
    }

    func selectedModelResponse(forSelectedModel selectedModel: SelectedModel,
                               conn: DatabaseConnectable) throws -> Future<SelectedModelResponse> {
        let modelFuture = Model
            .find(selectedModel.modelId, on: conn)
            .unwrap(or: RoasterHammerError.modelIsMissing.error())
            .flatMap(to: ModelResponse.self) { model in
                return try self.modelResponse(forModel: model, conn: conn)
        }
        let selectedWeaponsFuture = try selectedModel.weapons.query(on: conn).all()

        return map(to: SelectedModelResponse.self,
                   modelFuture,
                   selectedWeaponsFuture, { model, weapons in
                    return try SelectedModelResponse(selectedModel: selectedModel,
                                                     model: model,
                                                     selectedWeapons: weapons)
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
                                return try SelectedUnitResponse(selectedUnit: selectedUnit,
                                                                unit: unit,
                                                                models: selectedModels)
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
                                return try UnitResponse(unit: unit,
                                                        unitType: unitTypeString,
                                                        army: army,
                                                        models: modelResponses,
                                                        keywords: keywordStrings,
                                                        rules: rules)
                            })
        }
    }

    func modelResponse(forModel model: Model, conn: DatabaseConnectable) throws -> Future<ModelResponse> {
        let characteristicsFuture = try model.characteristics.query(on: conn).first().unwrap(or: RoasterHammerError.characteristicsAreMissing.error())
        let weaponsFuture = try model.weapons.query(on: conn).all()

        return flatMap(to: ModelResponse.self,
                       characteristicsFuture,
                       weaponsFuture, { (characteristics, weapons) in
                        let weaponController = WeaponController()
                        return try weapons
                            .map { try weaponController.weaponResponse(forWeapon: $0, model: model, conn: conn) }
                            .flatten(on: conn)
                            .map(to: ModelResponse.self, { (weaponResponses) in
                                return try ModelResponse(model: model,
                                                         characteristics: characteristics,
                                                         weapons: weaponResponses)
                            })
        })
    }

    func createUnit(request: CreateUnitRequest, conn: DatabaseConnectable) -> Future<Unit> {
        return Unit(name: request.name,
                    cost: request.cost,
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
                                keywords: [String],
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

    private func validateUnitInDetachment(detachment: Detachment,
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

    private func validateWeaponsForSelectedModel(selectedModel: SelectedModel,
                                                 conn: DatabaseConnectable) throws -> Future<Void> {
        let modelFuture = Model.find(selectedModel.modelId, on: conn).unwrap(or: RoasterHammerError.modelIsMissing.error())
        let attachedWeaponsFuture = try selectedModel.weapons.query(on: conn).all()

        return map(modelFuture, attachedWeaponsFuture) { model, attachedWeapons in
            if attachedWeapons.count >= model.weaponQuantity {
                throw RoasterHammerError.tooManyWeaponsForModel.error()
            }
        }
    }

}
