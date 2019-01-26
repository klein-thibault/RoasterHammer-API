@testable import App
import Vapor
import FluentPostgreSQL

final class GameTestsUtils {

    static func createGame(user: Customer, app: Application) throws -> GameResponse {
        let game = try app.getResponse(to: "games",
                                       method: .POST,
                                       decodeTo: GameResponse.self,
                                       loggedInRequest: true,
                                       loggedInCustomer: user)
        return game
    }

}
