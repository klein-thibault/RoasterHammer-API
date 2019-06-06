@testable import App
import XCTest
import RoasterHammer_Shared

class SelectedUnitResponseTests: XCTestCase {

    func testSelectedUnitResponseIsPsycher_whenUnitIsPsycher() {
        // Given
        let armyDTO = ArmyDTO(id: 1, name: "Army")
        let armyResponse = ArmyResponse(army: armyDTO,
                                        factions: [],
                                        rules: [],
                                        relics: [],
                                        warlordTraits: [],
                                        psychicPowers: [])
        let unitDTO = UnitDTO(id: 1,
                              name: "Unit",
                              isUnique: false,
                              minQuantity: 1,
                              maxQuantity: 1)
        let unitResponse = UnitResponse(unit: unitDTO,
                                        unitType: "Type",
                                        army: armyResponse,
                                        models: [],
                                        keywords: ["PSYCHER"],
                                        rules: [],
                                        availableWarlordTraits: [],
                                        availablePsychicPowers: [])
        let selectedUnitDTO = SelectedUnitDTO(id: 1, isWarlord: false)
        let selectedUnitResponse = SelectedUnitResponse(selectedUnit: selectedUnitDTO,

                                                        unit: unitResponse,
                                                        models: [],
                                                        warlordTrait: nil,
                                                        relic: nil,
                                                        psychicPower: nil)
        // Then
        XCTAssertTrue(selectedUnitResponse.isPsycher())
    }

    func testSelectedUnitResponseIsPsycher_whenUnitIsNotPsycher() {
        // Given
        let armyDTO = ArmyDTO(id: 1, name: "Army")
        let armyResponse = ArmyResponse(army: armyDTO,
                                        factions: [],
                                        rules: [],
                                        relics: [],
                                        warlordTraits: [],
                                        psychicPowers: [])
        let unitDTO = UnitDTO(id: 1,
                              name: "Unit",
                              isUnique: false,
                              minQuantity: 1,
                              maxQuantity: 1)
        let unitResponse = UnitResponse(unit: unitDTO,
                                        unitType: "Type",
                                        army: armyResponse,
                                        models: [],
                                        keywords: [],
                                        rules: [],
                                        availableWarlordTraits: [],
                                        availablePsychicPowers: [])
        let selectedUnitDTO = SelectedUnitDTO(id: 1, isWarlord: false)
        let selectedUnitResponse = SelectedUnitResponse(selectedUnit: selectedUnitDTO,

                                                        unit: unitResponse,
                                                        models: [],
                                                        warlordTrait: nil,
                                                        relic: nil,
                                                        psychicPower: nil)
        // Then
        XCTAssertFalse(selectedUnitResponse.isPsycher())
    }

}
