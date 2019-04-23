@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class WeaponTestsUtils {

    static func createPistolWeapon(app: Application) throws -> (request: CreateWeaponRequest, response: Weapon) {
        let request = CreateWeaponRequest(name: "Pistol",
                                          range: "12\"",
                                          type: "Pistol",
                                          strength: "3",
                                          armorPiercing: "0",
                                          damage: "1",
                                          cost: 15,
                                          ability: "-")
        let weapon = try app.getResponse(to: "weapons",
                                         method: .POST,
                                         headers: ["Content-Type": "application/json"],
                                         data: request,
                                         decodeTo: Weapon.self)

        return (request, weapon)
    }

    static func createBolterWeapon(app: Application) throws -> (request: CreateWeaponRequest, response: Weapon) {
        let request = CreateWeaponRequest(name: "Bolter",
                                          range: "24\"",
                                          type: "Rapid Fire 1",
                                          strength: "4",
                                          armorPiercing: "0",
                                          damage: "1",
                                          cost: 20,
                                          ability: "Can shoot at rapid fire if the model didn't move")
        let weapon = try app.getResponse(to: "weapons",
                                         method: .POST,
                                         headers: ["Content-Type": "application/json"],
                                         data: request,
                                         decodeTo: Weapon.self)

        return (request, weapon)
    }

    static func createHeavyWeapon(app: Application) throws -> (request: CreateWeaponRequest, response: Weapon) {
        let request = CreateWeaponRequest(name: "Heavy Bolter",
                                          range: "36\"",
                                          type: "Heavy 3",
                                          strength: "4",
                                          armorPiercing: "-2",
                                          damage: "2",
                                          cost: 30,
                                          ability: "Can shoot at rapid fire if the model didn't move")
        let weapon = try app.getResponse(to: "weapons",
                                         method: .POST,
                                         headers: ["Content-Type": "application/json"],
                                         data: request,
                                         decodeTo: Weapon.self)

        return (request, weapon)
    }

}
