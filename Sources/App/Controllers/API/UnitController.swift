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

    private let unitDatabaseQueries = UnitDatabaseQueries()
    
    // MARK: - Public Functions
    
    func createUnit(_ req: Request) throws -> Future<UnitResponse> {
        return try req.content.decode(CreateUnitRequest.self)
            .flatMap(to: Unit.self, { request in
                return self.unitDatabaseQueries.createUnit(request: request, conn: req)
            })
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitDatabaseQueries.unitResponse(forUnit: unit, conn: req)
            })
    }
    
    func units(_ req: Request) throws -> Future<[UnitResponse]> {
        let filters = try req.query.decode(UnitFilters.self)
        let armyId: Int? = (filters.armyId != nil) ? filters.armyId!.intValue : nil
        return self.unitDatabaseQueries.getUnits(armyId: armyId, unitType: filters.unitType, conn: req)
    }

    func getUnit(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        return self.unitDatabaseQueries.getUnit(byID: unitId, conn: req)
    }

    func editUnit(_ req: Request) throws -> Future<UnitResponse> {
        let unitId = try req.parameters.next(Int.self)
        return try req.content.decode(CreateUnitRequest.self)
            .flatMap(to: Unit.self, { request in
                return self.unitDatabaseQueries.editUnit(unitId: unitId, request: request, conn: req)
            })
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitDatabaseQueries.unitResponse(forUnit: unit, conn: req)
            })
    }

    func deleteUnit(_ req: Request) throws -> Future<HTTPStatus> {
        let unitId = try req.parameters.next(Int.self)
        return self.unitDatabaseQueries.deleteUnit(unitId: unitId, conn: req)
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
                        return try self.unitDatabaseQueries.validateAddingUnitToDetachment(detachment: detachment, role: role, unit: unit, conn: req)
                            .flatMap(to: SelectedUnit.self, { _ in
                                // Create the selected unit
                                return try self.unitDatabaseQueries.createSelectedUnit(unit: unit,
                                                                                       quantity: request.unitQuantity,
                                                                                       conn: req)
                            })
                            .flatMap(to: SelectedUnit.self, { selectedUnit in
                                // Create the default models of the selected unit
                                return try self.unitDatabaseQueries.createInitialModelsForSelectedUnit(unit: unit,
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
            return try self.unitDatabaseQueries.validateAddingModelInUnit(unit: unit, model: model, conn: req)
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
            return try self.unitDatabaseQueries.validateRemovingModelFromUnit(unit: unit, model: model, conn: req)
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
            let selectedModelId = try selectedModel.requireID()
            let weaponBucketId = try weaponBucket.requireID()
            let weaponId = try weapon.requireID()

            return req.eventLoop
                .future()
                .flatMap(to: Void.self, { _ in
                    // Automatically remove and reselect another weapon for the user if only 1 weapon can be selected
                    if weaponBucket.maxWeaponQuantity == 1 {
                        return self.unitDatabaseQueries.removeAllAttachedWeapons(fromWeaponBucket: weaponBucketId,
                                                                                 ofSelectedModel: selectedModelId,
                                                                                 conn: req)
                    } else {
                        return req.future()
                    }
                })
                .flatMap({ _ in
                    return try self.unitDatabaseQueries.validateWeaponsForSelectedModel(selectedModel: selectedModel,
                                                                                        weaponBucket: weaponBucket,
                                                                                        conn: req)
                })
                .flatMap(to: SelectedModelWeapon.self, { _ in
                    return self.unitDatabaseQueries.getOrCreateSelectedWeaponModel(selectedModelId: selectedModelId,
                                                                                   weaponBucketId: weaponBucketId,
                                                                                   weaponId: weaponId,
                                                                                   conn: req)
                })
                .flatMap(to: Detachment.self, { _ in
                    return Detachment.find(detachmentId, on: req).unwrap(or: RoasterHammerError.detachmentIsMissing.error())
                })
                .flatMap(to: DetachmentResponse.self, { detachment in
                    let detachmentController = DetachmentController()
                    return try detachmentController.getDetachmentById(detachmentId, conn: req)
                })
        })
    }

    func unattachWeaponFromSelectedModel(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let modelId = try req.parameters.next(Int.self)
        let weaponBucketId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)

        return unitDatabaseQueries.removeAttachedWeapon(weaponId: weaponId,
                                                        fromWeaponBucket: weaponBucketId,
                                                        ofSelectedModel: modelId,
                                                        conn: req)
            .flatMap(to: DetachmentResponse.self, { detachment in
                let detachmentController = DetachmentController()
                return try detachmentController.getDetachmentById(detachmentId, conn: req)
            })
    }

}
