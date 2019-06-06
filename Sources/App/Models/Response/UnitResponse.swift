import Vapor
import RoasterHammer_Shared

extension UnitResponse: Content { }

extension UnitResponse {
    func isPsycher() -> Bool {
        return keywords.map({$0.lowercased()}).contains(Constants.Keyword.psycher)
    }
}
