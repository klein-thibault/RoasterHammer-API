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

    // Rule
    let ruleController = RuleController()
    router.get("rules", use: ruleController.getRules)
    router.get("rules", Int.parameter, use: ruleController.getRuleById)
    router.post("rules", use: ruleController.createRule)

    // Roaster
    let roasterController = RoasterController()
    protectedAuthRouter.post("games", Int.parameter, "roasters", use: roasterController.createRoster)
    protectedAuthRouter.get("games", Int.parameter, "roasters", use: roasterController.getRoasters)
    router.get("roasters", Int.parameter, use: roasterController.getRoasterById)

    // Army
    let armyController = ArmyController()
    router.post("armies", use: armyController.createArmy)
    router.get("armies", use: armyController.armies)
    router.get("armies", Int.parameter, use: armyController.getArmy)
    router.patch("armies", Int.parameter, use: armyController.editArmy)
    router.delete("armies", Int.parameter, use: armyController.deleteArmy)
    router.get("armies", Int.parameter, "factions", use: armyController.getAllFactionsForArmy)

    // Faction
    let factionController = FactionController()
    router.post("armies", Int.parameter, "factions", use: factionController.createFaction)
    router.get("factions", use: factionController.getAllFactions)
    router.patch("factions", Int.parameter, use: factionController.editFaction)
    router.delete("factions", Int.parameter, use: factionController.deleteFaction)

    // Relic
    let relicController = RelicController()
    router.post("armies", Int.parameter, "relics", use: relicController.createRelic)
    router.delete("relics", Int.parameter, use: relicController.deleteRelic)

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
    router.get("units", Int.parameter, use: unitController.getUnit)
    router.patch("units", Int.parameter, use: unitController.editUnit)
    router.delete("units", Int.parameter, use: unitController.deleteUnit)
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
    protectedAuthRouter.patch("detachments",
                              Int.parameter,
                              "roles",
                              Int.parameter,
                              "units",
                              Int.parameter,
                              use: unitController.editSelectedUnit)
    protectedAuthRouter.patch("detachments",
                              Int.parameter,
                              "roles",
                              Int.parameter,
                              "units",
                              Int.parameter,
                              "warlord",
                              use: unitController.setUnitAsWarlord)
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
                             "weapon-buckets",
                             Int.parameter,
                             "weapons",
                             Int.parameter,
                             use: unitController.attachWeaponToSelectedModel)
    protectedAuthRouter.delete("detachments",
                               Int.parameter,
                               "models",
                               Int.parameter,
                               "weapon-buckets",
                               Int.parameter,
                               "weapons",
                               Int.parameter,
                               use: unitController.unattachWeaponFromSelectedModel)

    // Weapon
    let weaponController = WeaponController()
    router.post("weapons", use: weaponController.createWeapon)
    router.get("weapons", use: weaponController.getAllWeapons)
    router.get("weapons", Int.parameter, use: weaponController.getWeaponById)
    router.patch("weapons", Int.parameter, use: weaponController.editWeapon)
    router.delete("weapons", Int.parameter, use: weaponController.deleteWeapon)

    // Weapon Bucket
    let weaponBucketController = WeaponBucketController()
    router.post("weapon-buckets", use: weaponBucketController.createWeaponBucket)
    router.get("weapon-buckets", Int.parameter, use: weaponBucketController.getWeaponBucket)
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

    // Warlord Traits
    let warlordTraitsController = WarlordTraitController()
    router.post("armies", Int.parameter, "warlord-traits", use: warlordTraitsController.createWarlordTrait)
    router.delete("warlord-traits", Int.parameter, use: warlordTraitsController.deleteWarlordTrait)

    // Psychic Powers
    let psychicPowerController = PsychicPowerController()
    router.post("armies", Int.parameter, "psychic-powers", use: psychicPowerController.createPsychicPower)
    router.delete("psychic-powers", Int.parameter, use: psychicPowerController.deletePsychicPower)

    // Website
    let websiteController = WebsiteController()
    router.get("roasterhammer", use: websiteController.indexHandler)
    // - Units
    let websiteUnitController = WebsiteUnitController()
    router.get("roasterhammer", "units", use: websiteUnitController.unitsHandler)
    router.get("roasterhammer", "armies", Int.parameter, "units", Int.parameter, use: websiteUnitController.unitHandler)
    router.get("roasterhammer", "armies", Int.parameter, "units", "create", use: websiteUnitController.createUnitHandler)
    router.post(CreateUnitData.self,
                at: "roasterhammer", "armies", Int.parameter, "units", "create",
                use: websiteUnitController.createUnitPostHandler)
    router.get("roasterhammer", "units", Int.parameter, "edit", use: websiteUnitController.editUnitHandler)
    router.post(CreateUnitData.self,
                at: "roasterhammer", "units", Int.parameter, "edit",
                use: websiteUnitController.editUnitPostHandler)
    router.post("roasterhammer", "units", Int.parameter, "delete", use: websiteUnitController.deleteUnitHandler)
    router.get("roasterhammer", "armies", Int.parameter, "units", Int.parameter, "warlord-traits",
               use: websiteUnitController.warlordTraitsHandler)
    router.post(AssignWarlordTraitData.self,
                at: "roasterhammer", "armies", Int.parameter, "units", Int.parameter, "warlord-traits",
                use: websiteUnitController.warlordTraitsPostHandler)
    router.post("roasterhammer", "armies", Int.parameter, "units", Int.parameter, "warlord-traits", Int.parameter, "delete",
                use: websiteUnitController.deleteWarlordTraitFromUnitHandler)
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
    // - Weapon Buckets
    let websiteWeaponBucketController = WebsiteWeaponBucketController()
    router.get("roasterhammer", "models", Int.parameter, "weapon-buckets", use: websiteWeaponBucketController.weaponBucketsHandler)
    router.post(CreateWeaponBucketData.self,
                at: "roasterhammer", "models", Int.parameter, "weapon-buckets",
                use: websiteWeaponBucketController.createWeaponBucketPostHandler)
    router.get("roasterhammer", "weapon-buckets", Int.parameter, "edit", use: websiteWeaponBucketController.editWeaponBucketHandler)
    router.post(EditWeaponBucketData.self,
                at: "roasterhammer", "weapon-buckets", Int.parameter, "edit",
                use: websiteWeaponBucketController.editWeaponBucketPostHandler)
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
    router.get("roasterhammer", "armies", Int.parameter, "factions", "create", use: websiteFactionController.createFactionHandler)
    router.post(CreateFactionAndRulesData.self,
                at: "roasterhammer", "armies", Int.parameter, "factions", "create",
                use: websiteFactionController.createFactionPostHandler)
    router.get("roasterhammer", "armies", Int.parameter, "factions", Int.parameter, "edit", use: websiteFactionController.editFactionHandler)
    router.post(CreateFactionAndRulesData.self,
                at: "roasterhammer", "armies", Int.parameter, "factions", Int.parameter, "edit",
                use: websiteFactionController.editFactionPostHandler)
    router.post("roasterhammer", "armies", Int.parameter, "factions", Int.parameter, "delete", use: websiteFactionController.deleteFactionHandler)
    // - Rules
    let websiteRuleController = WebsiteRuleController()
    router.get("roasterhammer", "rules", use: websiteRuleController.rulesHandler)
    router.get("roasterhammer", "rules", "create", use: websiteRuleController.createRuleHandler)
    router.post(EditRuleData.self,
                at: "roasterhammer", "rules", "create",
                use: websiteRuleController.createRulePostHandler)
    router.get("roasterhammer", "rules", Int.parameter, use: websiteRuleController.ruleHandler)
    router.get("roasterhammer", "rules", Int.parameter, "edit", use: websiteRuleController.editRuleHandler)
    router.post(EditRuleData.self,
                at: "roasterhammer", "rules", Int.parameter, "edit",
                use: websiteRuleController.editRulePostHandler)
    router.post("roasterhammer", "rules", Int.parameter, "delete", use: websiteRuleController.deleteRuleHandler)
    // - Relics
    let websiteRelicController = WebsiteRelicController()
    router.get("roasterhammer", "armies", Int.parameter, "relics", use: websiteRelicController.relicsHandler)
    router.get("roasterhammer", "armies", Int.parameter, "relics", "create", use: websiteRelicController.createRelicHandler)
    router.post(CreateRelicData.self,
                at: "roasterhammer", "armies", Int.parameter, "relics", "create",
                use: websiteRelicController.createRelicPostHandler)
    router.post("roasterhammer", "armies", Int.parameter, "relics", Int.parameter, "delete",
                use: websiteRelicController.deleteRelicHandler)
    // - Warlord Traits
    let websiteWarlordTraitController = WebsiteWarlordTraitController()
    router.get("roasterhammer", "armies", Int.parameter, "warlord-traits", use: websiteWarlordTraitController.warlordTraitsHandler)
    router.get("roasterhammer", "armies", Int.parameter, "warlord-traits", "create", use: websiteWarlordTraitController.createWarlordTraitHandler)
    router.post(CreateWarlordTraitData.self,
                at: "roasterhammer", "armies", Int.parameter, "warlord-traits", "create",
                use: websiteWarlordTraitController.createWarlordTraitPostHandler)
    router.post("roasterhammer", "armies", Int.parameter, "warlord-traits", Int.parameter, "delete",
                use: websiteWarlordTraitController.deleteWarlordTraitHandler)

    // QA
    //    let qaController = QAController()
    //    router.post("qa/node", use: qaController.addNodeQA)
    //    router.get("qa/node", use: qaController.getNodeQA)
}
