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

    // Faction
    let factionController = FactionController()
    router.post("armies", Int.parameter, "factions", use: factionController.createFaction)
    router.get("factions", use: factionController.getAllFactions)
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
    router.get("roasterhammer/units", Int.parameter, use: websiteController.unitsHandler)
}
