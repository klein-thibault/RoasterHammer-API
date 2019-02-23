@testable import App
import Vapor
import FluentPostgreSQL

final class UnitTestsUtils {

    static func createHQUniqueUnit(armyId: Int, app: Application) throws -> (request: CreateUnitRequest, response: UnitResponse) {
        let characteristics = CreateCharacteristicsRequest(movement: "6\"",
                                                     weaponSkill: "2+",
                                                     balisticSkill: "2+",
                                                     strength: "5",
                                                     toughness: "4",
                                                     wounds: "6",
                                                     attacks: "5",
                                                     leadership: "9",
                                                     save: "3+")
        let keywords = ["Chaos", "Khorne"]
        let rules = [AddRuleRequest(name: "Blood for the Blood God", description: "This unit can attack twice during the fight phase")]
        let unitTypes = try app.getResponse(to: "unit-types", decodeTo: [UnitType].self)
        let hqUnitType = unitTypes.filter({$0.name == "HQ"}).first!
        let createModelRequest = CreateModelRequest(name: "Kharn",
                                                    cost: 120,
                                                    minQuantity: 1,
                                                    maxQuantity: 1,
                                                    weaponQuantity: 1,
                                                    characteristics: characteristics)

        let createUnitRequest = try CreateUnitRequest(name: "Kharn",
                                                      isUnique: true,
                                                      minQuantity: 1,
                                                      maxQuantity: 1,
                                                      unitTypeId: hqUnitType.requireID(),
                                                      armyId: armyId,
                                                      models: [createModelRequest],
                                                      keywords: keywords,
                                                      rules: rules)
        let unit = try app.getResponse(to: "units",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createUnitRequest,
                                       decodeTo: UnitResponse.self)

        return (createUnitRequest, unit)
    }

    static func createHQUnit(armyId: Int, app: Application) throws -> (request: CreateUnitRequest, response: UnitResponse) {
        let characteristics = CreateCharacteristicsRequest(movement: "6\"",
                                                           weaponSkill: "2+",
                                                           balisticSkill: "2+",
                                                           strength: "5",
                                                           toughness: "4",
                                                           wounds: "6",
                                                           attacks: "5",
                                                           leadership: "9",
                                                           save: "3+")
        let keywords = ["Chaos", "Khorne"]
        let rules = [AddRuleRequest(name: "Blood for the Blood God", description: "This unit can attack twice during the fight phase")]
        let unitTypes = try app.getResponse(to: "unit-types", decodeTo: [UnitType].self)
        let hqUnitType = unitTypes.filter({$0.name == "HQ"}).first!
        let createModelRequest = CreateModelRequest(name: "Chaos Lord",
                                                    cost: 70,
                                                    minQuantity: 1,
                                                    maxQuantity: 1,
                                                    weaponQuantity: 1,
                                                    characteristics: characteristics)

        let createUnitRequest = try CreateUnitRequest(name: "Chaos Lord",
                                                      isUnique: false,
                                                      minQuantity: 1,
                                                      maxQuantity: 1,
                                                      unitTypeId: hqUnitType.requireID(),
                                                      armyId: armyId,
                                                      models: [createModelRequest],
                                                      keywords: keywords,
                                                      rules: rules)
        let unit = try app.getResponse(to: "units",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: createUnitRequest,
                                       decodeTo: UnitResponse.self)

        return (createUnitRequest, unit)
    }

}
