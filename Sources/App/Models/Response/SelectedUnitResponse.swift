import Vapor
import RoasterHammer_Shared

extension SelectedUnitResponse: Content { }

extension SelectedUnitResponse {
    func isPsycher() -> Bool {
        return unit.isPsycher()
    }
}
