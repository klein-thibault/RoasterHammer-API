@testable import App
import Vapor
import FluentPostgreSQL

final class WeaponTestsUtils {

    static func createWeapon(app: Application) throws -> (request: CreateWeaponRequest, response: Weapon) {
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

}
