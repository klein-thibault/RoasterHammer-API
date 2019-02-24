@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class RoasterTestsUtils {

    static func createRoaster(user: Customer, gameId: Int, app: Application) throws -> (request: CreateRoasterRequest, response: RoasterResponse) {
        let request = CreateRoasterRequest(name: "My Roaster")
        let roaster = try app.getResponse(to: "games/\(gameId)/roasters",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: request,
            decodeTo: RoasterResponse.self,
            loggedInRequest: true,
            loggedInCustomer: user)

        return (request, roaster)
    }

}
