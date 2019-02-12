import Vapor
import Leaf

struct WebsiteWeaponController {

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
        let cost = createWeaponRequest.cost.intValue ?? 0
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

}
