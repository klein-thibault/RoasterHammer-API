import Vapor
import Leaf

struct WebsiteController {

    func indexHandler(_ req: Request) throws -> Future<View> {
        return try ArmyController().armies(req).flatMap(to: View.self, { armies in
            let context = IndexContext(title: "Homepage", armies: armies)
            return try req.view().render("index", context)
        })
    }

    func unitsHandler(_ req: Request) throws -> Future<View> {
        return UnitController()
            .getUnits(armyId: nil, conn: req)
            .flatMap(to: View.self, { units in
                let context = UnitsContext(title: "Units", units: units)
                return try req.view().render("units", context)
            })
    }

    func weaponsHandler(_ req: Request) throws -> Future<View> {
        return WeaponController()
            .getAllWeapons(conn: req)
            .flatMap(to: View.self, { weapons in
                let context = WeaponsContext(title: "Weapons", weapons: weapons)
                return try req.view().render("weapons", context)
            })
    }

    func createWeaponHandler(_ req: Request) throws -> Future<View> {
        let context = CreateWeaponContext(title: "Create A Weapon")
        return try req.view().render("createWeapon", context)
    }

    func createWeaponPostHandler(_ req: Request,
                                 createWeaponRequest: CreateWeaponData) throws -> Future<Response> {
        let cost = Int(createWeaponRequest.cost) ?? 0
        let newWeaponRequest = CreateWeaponRequest(name: createWeaponRequest.name,
                                                   range: createWeaponRequest.range,
                                                   type: createWeaponRequest.type,
                                                   strength: createWeaponRequest.strength,
                                                   armorPiercing: createWeaponRequest.armorPiercing,
                                                   damage: createWeaponRequest.damage,
                                                   cost: cost,
                                                   ability: createWeaponRequest.ability)

        return WeaponController()
            .createWeapon(request: newWeaponRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer/weapons")
            })
    }

    func armyHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return try ArmyController()
            .getArmy(byID: armyId, conn: req)
            .flatMap(to: View.self, { army in
                let context = ArmyContext(army: army)
                return try req.view().render("army", context)
            })
    }

    func createArmyHandler(_ req: Request) throws -> Future<View> {
        let context = CreateArmyContext(title: "Create An Army")
        return try req.view().render("createArmy", context)
    }

    func createArmyPostHandler(_ req: Request, createArmyRequest: CreateArmyAndRulesData) throws -> Future<Response> {
        let rules = addRuleRequest(forRuleData: createArmyRequest.rules)
        let newArmyRequest = CreateArmyRequest(name: createArmyRequest.armyName,
                                               rules: rules)

        return ArmyController()
            .createArmy(request: newArmyRequest, conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

    func createFactionHandler(_ req: Request) throws -> Future<View> {
        return try ArmyController().armies(req).flatMap(to: View.self, { armies in
            let context = CreateFactionContext(title: "Create A Faction", armies: armies)
            return try req.view().render("createFaction", context)
        })
    }

    func createFactionPostHandler(_ req: Request, createFactionRequest: CreateFactionAndRulesData) throws -> Future<Response> {
        let rules = addRuleRequest(forRuleData: createFactionRequest.rules)
        let newFactionRequest = CreateFactionRequest(name: createFactionRequest.factionName, rules: rules)

        return FactionController()
            .createFaction(armyId: createFactionRequest.armyId,
                           request: newFactionRequest,
                           conn: req)
            .map(to: Response.self, { _ in
                return req.redirect(to: "/roasterhammer")
            })
    }

    // MARK: - Private Functions

    private func addRuleRequest(forRuleData ruleData: [String: NewRuleContext]) -> [AddRuleRequest] {
        var rules: [AddRuleRequest] = []
        for ruleDictionary in ruleData.values {
            if let ruleName = ruleDictionary["name"], ruleName.count > 0,
                let ruleDescription = ruleDictionary["description"], ruleDescription.count > 0 {
                let rule = AddRuleRequest(name: ruleName,
                                          description: ruleDescription)
                rules.append(rule)
            }
        }

        return rules
    }

}

protocol WebContextTitle {
    var title: String { get }
}

protocol AddRuleData {
    var rules: [String: NewRuleContext] { get }
}

struct IndexContext: WebContextTitle, Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct UnitsContext: WebContextTitle, Encodable {
    let title: String
    let units: [UnitResponse]
}

struct CreateArmyContext: WebContextTitle, Encodable {
    let title: String
}

typealias NewRuleContext = [String: String]

struct CreateArmyAndRulesData: AddRuleData, Content {
    let armyName: String
    let rules: [String: NewRuleContext]
}

struct CreateFactionContext: WebContextTitle, Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct CreateFactionAndRulesData: AddRuleData, Content {
    let factionName: String
    let armyId: Int
    let rules: [String: NewRuleContext]
}

struct ArmyContext: Encodable {
    let army: ArmyResponse
}

struct WeaponsContext: Encodable {
    let title: String
    let weapons: [Weapon]
}

struct CreateWeaponContext: WebContextTitle, Encodable {
    let title: String
}

struct CreateWeaponData: Content {
    let name: String
    let range: String
    let type: String
    let strength: String
    let armorPiercing: String
    let damage: String
    let cost: String
    let ability: String
}
