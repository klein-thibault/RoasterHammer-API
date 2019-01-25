import Vapor
import FluentPostgreSQL

final class UnitController {
    
    // MARK: - Public Functions
    
    func createUnit(_ req: Request) throws -> Future<UnitResponse> {
        return try req.content.decode(CreateUnitRequest.self)
            .flatMap(to: Unit.self, { request in
                return Unit(name: request.name,
                            cost: request.cost,
                            isUnique: request.isUnique)
                    .save(on: req)
                    .flatMap(to: Unit.self, { unit in
                        return try self.createCharacteristics(forUnit: unit,
                                                              characteristics: request.characteristics,
                                                              conn: req)
                    })
                    .flatMap(to: Unit.self, { unit in
                        return self.createKeywords(forUnit: unit,
                                                   keywords: request.keywords,
                                                   conn: req)
                    })
            })
            .flatMap(to: UnitResponse.self, { unit in
                return try self.unitResponse(forUnit: unit, conn: req)
            })
    }
    
    func units(_ req: Request) throws -> Future<[UnitResponse]> {
        return Unit.query(on: req).all()
            .flatMap(to: [UnitResponse].self, { units in
                return try units.map { try self.unitResponse(forUnit: $0, conn: req) }.flatten(on: req)
            })
    }
    
    func addUnitToDetachmentUnitRole(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let roleId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)
        
        return Role.find(roleId, on: req)
            .unwrap(or: RoasterHammerError.roleIsMissing)
            .flatMap(to: UnitRole.self, { role in
                return Unit.find(unitId, on: req)
                    .unwrap(or: RoasterHammerError.unitIsMissing)
                    .flatMap(to: SelectedUnit.self, { unit in
                        return try SelectedUnit(unitId: unit.requireID()).save(on: req)
                    })
                    .flatMap(to: UnitRole.self, { unit in
                        return role.units.attach(unit, on: req)
                    })
            })
            .flatMap(to: Detachment.self, { _ in
                return Detachment.find(detachmentId, on: req)
                    .unwrap(or: RoasterHammerError.detachmentIsMissing)
            })
            .flatMap(to: DetachmentResponse.self, { detachment in
                let detachmentController = DetachmentController()
                return try detachmentController.detachmentResponse(forDetachment: detachment, conn: req)
            })
    }
    
    func attachWeaponToUnit(_ req: Request) throws -> Future<DetachmentResponse> {
        _ = try req.requireAuthenticated(Customer.self)
        let detachmentId = try req.parameters.next(Int.self)
        let unitId = try req.parameters.next(Int.self)
        let weaponId = try req.parameters.next(Int.self)
        
        let selectedUnitFuture = SelectedUnit.find(unitId, on: req).unwrap(or: RoasterHammerError.unitIsMissing)
        let weaponFuture = Weapon.find(weaponId, on: req).unwrap(or: RoasterHammerError.weaponIsMissing)
        
        return flatMap(selectedUnitFuture, weaponFuture, { (selectedUnit, weapon) in
            return selectedUnit.weapons.attach(weapon, on: req).save(on: req)
                .flatMap(to: Detachment.self, { _ in
                    return Detachment.find(detachmentId, on: req)
                        .unwrap(or: RoasterHammerError.detachmentIsMissing)
                })
                .flatMap(to: DetachmentResponse.self, { detachment in
                    let detachmentController = DetachmentController()
                    return try detachmentController.detachmentResponse(forDetachment: detachment, conn: req)
                })
        })
    }
    
    // MARK: - Utility Functions
    
    func unitResponse(forSelectedUnit selectedUnit: SelectedUnit, conn: DatabaseConnectable) throws -> Future<SelectedUnitResponse> {
        let unitFuture = Unit.find(selectedUnit.unitId, on: conn).unwrap(or: RoasterHammerError.unitIsMissing)
            .flatMap(to: UnitResponse.self) { (unit) in
                return try self.unitResponse(forUnit: unit, conn: conn)
        }
        let selectedWeaponsFuture = try selectedUnit.weapons.query(on: conn).all()
        
        return map(unitFuture,
                   selectedWeaponsFuture, { (unit, selectedWeapons) in
                    return try SelectedUnitResponse(selectedUnit: selectedUnit, unit: unit, selectedWeapons: selectedWeapons)
        })
    }
    
    func unitResponse(forUnit unit: Unit, conn: DatabaseConnectable) throws -> Future<UnitResponse> {
        let unitCharacteristicsFuture = try unit.characteristics.query(on: conn).first().unwrap(or: RoasterHammerError.unitIsMissing)
        let unitWeaponsFuture = try unit.weapons.query(on: conn).all()
        let unitKeywordsFuture = try unit.keywords.query(on: conn).all()
        
        return map(to: UnitResponse.self,
                   unitCharacteristicsFuture,
                   unitWeaponsFuture,
                   unitKeywordsFuture) { (characteristics, weapons, keywords) in
                    return try UnitResponse(unit: unit,
                                            characteristics: characteristics,
                                            weapons: weapons,
                                            keywords: keywords.map { $0.name} )
        }
    }

    // MARK: - Private Functions

    private func createCharacteristics(forUnit unit: Unit,
                                       characteristics: CharacteristicsRequest,
                                       conn: DatabaseConnectable) throws -> Future<Unit> {
        let unitId = try unit.requireID()
        return Characteristics(movement: characteristics.movement,
                               weaponSkill: characteristics.weaponSkill,
                               balisticSkill: characteristics.balisticSkill,
                               strength: characteristics.strength,
                               toughness: characteristics.toughness,
                               wounds: characteristics.wounds,
                               attacks: characteristics.attacks,
                               leadership: characteristics.leadership,
                               save: characteristics.save,
                               unitId: unitId)
            .save(on: conn)
            .map(to: Unit.self, { _ in
                return unit
            })
    }

    private func createKeywords(forUnit unit: Unit,
                                keywords: [UnitKeywordRequest],
                                conn: DatabaseConnectable) -> Future<Unit> {
        let keywordsFuture = keywords.map { Keyword(name: $0.name).save(on: conn) }.flatten(on: conn)
        return keywordsFuture
            .flatMap(to: [UnitKeyword].self) { keywords in
                return keywords.map { unit.keywords.attach($0, on: conn) }.flatten(on: conn)
        }
            .map(to: Unit.self, { _ in
                return unit
            })
    }
    
}
