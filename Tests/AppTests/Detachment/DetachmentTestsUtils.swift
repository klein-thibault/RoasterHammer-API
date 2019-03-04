@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class DetachmentTestsUtils {

    static func createPatrolDetachmentWithArmy(app: Application) throws -> (request: CreateDetachmentRequest, response: DetachmentResponse) {
        let (_, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)

        let request = CreateDetachmentRequest(name: Constants.DetachmentName.patrol, commandPoints: 0, armyId: army.id!)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: request,
                                             decodeTo: DetachmentResponse.self)

        return (request, detachment)
    }
}
