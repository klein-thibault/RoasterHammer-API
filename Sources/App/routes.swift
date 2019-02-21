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
    protectedAuthRouter.post("detachments",
                             Int.parameter,
                             "roles",
                             Int.parameter,
                             "units",
                             Int.parameter,
                             use: unitController.addUnitToDetachmentUnitRole)
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
    router.get("weapons", Int.parameter, use: weaponController.getWeaponById)
    router.post("units",
                Int.parameter,
                "models",
                Int.parameter,
                "weapons",
                Int.parameter,
                use: weaponController.addWeaponToModel)

    // Website
    let websiteController = WebsiteController()
    router.get("roasterhammer", use: websiteController.indexHandler)
    // - Units
    let websiteUnitController = WebsiteUnitController()
    router.get("roasterhammer", "units", use: websiteUnitController.unitsHandler)
    router.get("roasterhammer", "units", "create", use: websiteUnitController.createUnitHandler)
    router.post(CreateUnitData.self,
                at: "roasterhammer", "units", "create",
                use: websiteUnitController.createUnitPostHandler)
    // - Weapons
    let websiteWeaponController = WebsiteWeaponController()
    router.get("roasterhammer", "weapons", use: websiteWeaponController.weaponsHandler)
    router.get("roasterhammer", "weapons", "create", use: websiteWeaponController.createWeaponHandler)
    router.post(CreateWeaponData.self,
                at: "roasterhammer", "weapons", "create",
                use: websiteWeaponController.createWeaponPostHandler)
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

    // QA
//    let qaController = QAController()
//    router.post("qa/node", use: qaController.addNodeQA)
//    router.get("qa/node", use: qaController.getNodeQA)
}
