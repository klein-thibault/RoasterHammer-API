import Vapor

struct CreateRoasterRequest: Content {
    var name: String
    var gameId: Int
}
