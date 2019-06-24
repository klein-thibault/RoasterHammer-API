import Vapor
import RoasterHammer_Shared

extension PsychicPowerResponse: Content { }
extension PsychicPowerResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: PsychicPowerResponse, rhs: PsychicPowerResponse) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.description == rhs.description
    }
}
