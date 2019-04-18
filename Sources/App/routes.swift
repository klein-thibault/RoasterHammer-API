import Vapor
import Leaf
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Authentication middleware
    let basicAuthMiddleware = Customer.basicAuthMiddleware(using: BCryptDigest())
    let protectedBasicRouter = router.grouped(basicAuthMiddleware)
    let tokenAuthMiddleware = Customer.tokenAuthMiddleware()
    let protectedAuthRouter = router.grouped(tokenAuthMiddleware)

    // User
    let userController = UserController()
    router.post("users/register", use: userController.createUser)
    protectedBasicRouter.post("users/login", use: userController.loginUser)
    protectedAuthRouter.get("users", use: userController.getUser)

    // Game
    let gameController = GameController()
    protectedAuthRouter.post("games", use: gameController.createGame)
    protectedAuthRouter.get("games", use: gameController.games)
    protectedAuthRouter.get("games", Int.parameter, use: gameController.gameById)

    // Roaster
    let roasterController = RoasterController()
    protectedAuthRouter.post("games", Int.parameter, "roasters", use: roasterController.createRoster)
    protectedAuthRouter.get("games", Int.parameter, "roasters", use: roasterController.getRoasters)
    router.get("roasters", Int.parameter, use: roasterController.getRoasterById)

    // Army
    let armyController = ArmyController()
    router.post("armies", use: armyController.createArmy)
    router.get("armies", use: armyController.armies)
    router.patch("armies", Int.parameter, use: armyController.editArmy)
    router.delete("armies", Int.parameter, use: armyController.deleteArmy)

    // Faction
    let factionController = FactionController()
    router.post("armies", Int.parameter, "factions", use: factionController.createFaction)
    router.get("factions", use: factionController.getAllFactions)
    router.patch("factions", Int.parameter, use: factionController.editFaction)
    router.delete("factions", Int.parameter, use: factionController.deleteFaction)

    // Detachment
    let detachmentController = DetachmentController()
    router.post("detachments", use: detachmentController.createDetachment)
    router.get("detachments", use: detachmentController.detachments)
    router.get("detachment-types", use: detachmentController.detachmentTypes)
    protectedAuthRouter.post("roasters",
                             Int.parameter,
                             "detachments",
                             use: detachmentController.addDetachmentToRoaster)
    protectedAuthRouter.post("roasters",
                             Int.parameter,
                             "detachments",
                             Int.parameter,
                             "factions",
                             Int.parameter,
                             use: detachmentController.selectDetachmentFaction)

    // UnitType
    let unitTypeController = UnitTypeController()
    router.get("unit-types", use: unitTypeController.getAllUnitTypes)

    // Unit
    let unitController = UnitController()
    router.post("units", use: unitController.createUnit)
    router.get("units", use: unitController.units)
    router.patch("units", Int.parameter, use: unitController.editUnit)
    protectedAuthRouter.post("detachments",
                             Int.parameter,
                             "roles",
                             Int.parameter,
                             "units",
                             Int.parameter,
                             use: unitController.addUnitToDetachmentUnitRole)
    protectedAuthRouter.delete("detachments",
                               Int.parameter,
                               "roles",
                               Int.parameter,
                               "units",
                               Int.parameter,
                               use: unitController.removeUnitFromDetachmentUnitRole)
    protectedAuthRouter.post("detachments",
                             Int.parameter,
                             "units",
                             Int.parameter,
                             "models",
                             Int.parameter,
                             use: unitController.addModelToUnit)
    protectedAuthRouter.delete("detachments",
                               Int.parameter,
                               "units",
                               Int.parameter,
                               "models",
                               Int.parameter,
                               use: unitController.removeModelFromUnit)
    protectedAuthRouter.post("detachments",
                             Int.parameter,
                             "models",
                             Int.parameter,
                             "weapons",
                             Int.parameter,
                             use: unitController.attachWeaponToSelectedModel)

    // Weapon
    let weaponController = WeaponController()
    router.post("weapons", use: weaponController.createWeapon)
    router.get("weapons", use: weaponController.getAllWeapons)
    router.get("weapons", "models", Int.parameter, use: weaponController.getWeaponsForModel)
    router.get("weapons", Int.parameter, use: weaponController.getWeaponById)
    router.post("units",
                Int.parameter,
                "models",
                Int.parameter,
                "weapons",
                Int.parameter,
                use: weaponController.addWeaponToModel)
    router.patch("weapons", Int.parameter, use: weaponController.editWeapon)
    router.delete("weapons", Int.parameter, use: weaponController.deleteWeapon)

    // Weapon Bucket
    let weaponBucketController = WeaponBucketController()
    router.post("weapon-buckets", use: weaponBucketController.createWeaponBucket)
    router.post("weapon-buckets",
                Int.parameter,
                "models",
                Int.parameter,
                use: weaponBucketController.assignModelToWeaponBucket)
    router.post("weapon-buckets",
                Int.parameter,
                "weapons",
                Int.parameter,
                use: weaponBucketController.assignWeaponToWeaponBucket)

    // Website
    let websiteController = WebsiteController()
    router.get("roasterhammer", use: websiteController.indexHandler)
    // - Units
    let websiteUnitController = WebsiteUnitController()
    router.get("roasterhammer", "units", use: websiteUnitController.unitsHandler)
    router.get("roasterhammer", "units", Int.parameter, use: websiteUnitController.unitHandler)
    router.get("roasterhammer", "units", "create", use: websiteUnitController.createUnitHandler)
    router.post(CreateUnitData.self,
                at: "roasterhammer", "units", "create",
                use: websiteUnitController.createUnitPostHandler)
    router.get("roasterhammer", "units", Int.parameter, "edit", use: websiteUnitController.editUnitHandler)
    router.get("roasterhammer", "units", Int.parameter, "assign-weapon", use: websiteUnitController.assignWeaponHandler)
    router.post(AssignWeaponData.self,
                at: "roasterhammer", "units", Int.parameter, "assign-weapon",
                use: websiteUnitController.assignWeaponPostHandler)
    router.post(CreateUnitData.self,
                at: "roasterhammer", "units", Int.parameter, "edit",
                use: websiteUnitController.editUnitPostHandler)
    router.post("roasterhammer", "units", Int.parameter, "delete", use: websiteUnitController.deleteUnitHandler)
    // - Weapons
    let websiteWeaponController = WebsiteWeaponController()
    router.get("roasterhammer", "weapons", use: websiteWeaponController.weaponsHandler)
    router.get("roasterhammer", "weapons", "create", use: websiteWeaponController.createWeaponHandler)
    router.post(CreateWeaponData.self,
                at: "roasterhammer", "weapons", "create",
                use: websiteWeaponController.createWeaponPostHandler)
    router.get("roasterhammer", "weapons", Int.parameter, "edit", use: websiteWeaponController.editWeaponHandler)
    router.post(CreateWeaponData.self,
                at: "roasterhammer", "weapons", Int.parameter, "edit",
                use: websiteWeaponController.editWeaponPostHandler)
    router.post("roasterhammer", "weapons", Int.parameter, "delete", use: websiteWeaponController.deleteWeaponHandler)
    // - Armies
    let websiteArmyController = WebsiteArmyController()
    router.get("roasterhammer", "armies", Int.parameter, use: websiteArmyController.armyHandler)
    router.get("roasterhammer", "armies", "create", use: websiteArmyController.createArmyHandler)
    router.post(CreateArmyAndRulesData.self,
                at: "roasterhammer", "armies", "create",
                use: websiteArmyController.createArmyPostHandler)
    router.get("roasterhammer", "armies", Int.parameter, "edit", use: websiteArmyController.editArmyHandler)
    router.post(CreateArmyAndRulesData.self,
                at: "roasterhammer", "armies", Int.parameter, "edit",
                use: websiteArmyController.editArmyPostHandler)
    router.post("roasterhammer", "armies", Int.parameter, "delete", use: websiteArmyController.deleteArmyHandler)
    // - Factions
    let websiteFactionController = WebsiteFactionController()
    router.get("roasterhammer", "factions", "create", use: websiteFactionController.createFactionHandler)
    router.post(CreateFactionAndRulesData.self,
                at: "roasterhammer", "factions", "create",
                use: websiteFactionController.createFactionPostHandler)
    router.get("roasterhammer", "factions", Int.parameter, "edit", use: websiteFactionController.editFactionHandler)
    router.post(CreateFactionAndRulesData.self,
                at: "roasterhammer", "factions", Int.parameter, "edit",
                use: websiteFactionController.editFactionPostHandler)
    router.post("roasterhammer", "factions", Int.parameter, "delete", use: websiteFactionController.deleteFactionHandler)

    // QA
    //    let qaController = QAController()
    //    router.post("qa/node", use: qaController.addNodeQA)
    //    router.get("qa/node", use: qaController.getNodeQA)
}
