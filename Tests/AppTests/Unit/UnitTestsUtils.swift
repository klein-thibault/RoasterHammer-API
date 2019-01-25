@testable import App
import Vapor
import FluentPostgreSQL

final class UnitTestsUtils {

    static func createUnit(app: Application) throws -> (request: CreateUnitRequest, response: UnitResponse) {
        let characteristics = CharacteristicsRequest(movement: "6\"",
                                                     weaponSkill: "2+",
                                                     balisticSkill: "2+",
                                                     strength: "5",
                                                     toughness: "4",
                                                     wounds: "6",
                                                     attacks: "5",
                                                     leadership: "9",
                                                     save: "3+")
        let keywords = [UnitKeywordRequest(name: "Chaos"), UnitKeywordRequest(name: "Khorne")]
        let createUnitRequest = CreateUnitRequest(name: "Kharn",
                                                  cost: 120,
                                                  isUnique: true,
                                                  characteristics: characteristics,
                                                  keywords: keywords)
        let unit = try app.getResponse(to: "units",
                                   method: .POST,
                                   headers: ["Content-Type": "application/json"],
                                   data: createUnitRequest,
                                   decodeTo: UnitResponse.self)

        return (createUnitRequest, unit)
    }

}
