import Vapor
import RoasterHammer_Shared

extension WarlordTraitResponse: Content { }
extension WarlordTraitResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: WarlordTraitResponse, rhs: WarlordTraitResponse) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.description == rhs.description
    }
}
