@testable import App
import Vapor
import FluentPostgreSQL

final class DetachmentTestsUtils {

    static func createPatrolDetachmentWithArmy(app: Application) throws -> (request: CreateDetachmentRequest, response: Detachment) {
        let (_, army) = try ArmyTestsUtils.createArmyWithFaction(app: app)

        let request = CreateDetachmentRequest(name: "Patrol", commandPoints: 0, armyId: army.id!)
        let detachment = try app.getResponse(to: "detachments",
                                             method: .POST,
                                             headers: ["Content-Type": "application/json"],
                                             data: request,
                                             decodeTo: Detachment.self)

        return (request, detachment)
    }
}
