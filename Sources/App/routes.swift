import Vapor
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

    // Army
    let armyController = ArmyController()
    router.post("armies", use: armyController.createArmy)
    router.get("armies", use: armyController.armies)
    protectedAuthRouter.post("roasters", Int.parameter, "armies", use: armyController.addArmyToRoaster)

    // Detachment
    let detachmentController = DetachmentController()
    router.post("detachments", use: detachmentController.createDetachment)
    router.get("detachments", use: detachmentController.detachments)
    protectedAuthRouter.post("armies", Int.parameter, "detachments", use: detachmentController.addDetachmentToArmy)

    // Unit
    let unitController = UnitController()
    router.post("units", use: unitController.createUnit)
    router.get("units", use: unitController.units)
    protectedAuthRouter.post("detachments", Int.parameter, "roles", Int.parameter, "units", Int.parameter, use: unitController.addUnitToDetachmentUnitRole)
}
