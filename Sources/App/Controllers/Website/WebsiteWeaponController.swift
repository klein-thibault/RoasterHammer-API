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
            .transform(to: req.redirect(to: "/roasterhammer/weapons"))
    }

    func editWeaponHandler(_ req: Request) throws -> Future<View> {
        let weaponId = try req.parameters.next(Int.self)

        return WeaponController().getWeapon(byID: weaponId, conn: req)
            .flatMap(to: View.self, { weapon in
                let context = EditWeaponContext(title: "Edit Weapon", weapon: weapon)
                return try req.view().render("createWeapon", context)
            })
    }

    func editWeaponPostHandler(_ req: Request,
                               editWeaponRequest: CreateWeaponData) throws -> Future<Response> {
        let weaponId = try req.parameters.next(Int.self)

        return WeaponController()
            .editWeapon(weaponId: weaponId, request: editWeaponRequest, conn: req)
            .transform(to: req.redirect(to: "/roasterhammer/weapons"))
    }

    func deleteWeaponHandler(_ req: Request) throws -> Future<Response> {
        let weaponId = try req.parameters.next(Int.self)
        return WeaponController()
        .deleteWeapon(weaponId: weaponId, conn: req)
        .transform(to: req.redirect(to: "/roasterhammer/weapons"))
    }

}
