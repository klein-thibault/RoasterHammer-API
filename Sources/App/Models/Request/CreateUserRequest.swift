import Vapor

struct CreateUserRequest: Content {
    var email: String
    var password: String
}

