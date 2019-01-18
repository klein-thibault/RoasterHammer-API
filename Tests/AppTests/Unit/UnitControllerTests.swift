@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class UnitControllerTests: BaseTests {

    func testCreateUnit() throws {
        let characteristics = CharacteristicsRequest(movement: "6\"",
                                              weaponSkill: "2+",
                                              balisticSkill: "2+",
                                              strength: "5",
                                              toughness: "4",
                                              wounds: "6",
                                              attacks: "5",
                                              leadership: "9",
                                              save: "3+")
        let request = CreateUnitRequest(name: "Kharn", cost: 120, characteristics: characteristics)

        let unit = try app.getResponse(to: "units",
                                       method: .POST,
                                       headers: ["Content-Type": "application/json"],
                                       data: request,
                                       decodeTo: Unit.self)
        let unitCharacteristics = try unit.characteristics.query(on: conn).filter(\.unitId == unit.id!).first().wait()

        XCTAssertNotNil(unit.id)
        XCTAssertEqual(unit.name, request.name)
        XCTAssertEqual(unit.cost, request.cost)
        XCTAssertEqual(unitCharacteristics?.movement, request.characteristics.movement)
        XCTAssertEqual(unitCharacteristics?.weaponSkill, request.characteristics.weaponSkill)
        XCTAssertEqual(unitCharacteristics?.balisticSkill, request.characteristics.balisticSkill)
        XCTAssertEqual(unitCharacteristics?.strength, request.characteristics.strength)
        XCTAssertEqual(unitCharacteristics?.toughness, request.characteristics.toughness)
        XCTAssertEqual(unitCharacteristics?.wounds, request.characteristics.wounds)
        XCTAssertEqual(unitCharacteristics?.attacks, request.characteristics.attacks)
        XCTAssertEqual(unitCharacteristics?.leadership, request.characteristics.leadership)
        XCTAssertEqual(unitCharacteristics?.save, request.characteristics.save)
    }
}
