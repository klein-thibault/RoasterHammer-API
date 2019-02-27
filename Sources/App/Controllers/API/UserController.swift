import Vapor
import FluentPostgreSQL
import Crypto
import RoasterHammer_Shared

final class UserController {

    // MARK: - Public Functions

    func createUser(_ req: Request) throws -> Future<UserResponse> {
        return try req.content.decode(CreateUserRequest.self)
            .flatMap(to: Customer.Public.self, { request in
                let encryptedPassword = try BCrypt.hash(request.password)
                let customer = Customer(customerId: UUID().uuidString,
                                        email: request.email,
                                        password: encryptedPassword)
                return customer.save(on: req).convertToPublic()
            })
            .map(to: UserResponse.self, { user in
                return self.userResponse(forUser: user)
            })
    }

    func loginUser(_ req: Request) throws -> Future<AuthTokenResponse> {
        let customer = try req.requireAuthenticated(Customer.self)
        let token = try UserToken.generate(for: customer)
        return token.save(on: req)
            .map(to: AuthTokenResponse.self, { token in
                return self.authToken(forUserToken: token)
            })
    }

    func getUser(_ req: Request) throws -> Future<UserResponse> {
        let customer = try req.requireAuthenticated(Customer.self)
        let promiseCustomer = req.eventLoop.newPromise(UserResponse.self)
        let user = customer.convertToPublic()
        let response = userResponse(forUser: user)
        promiseCustomer.succeed(result: response)
        return promiseCustomer.futureResult
    }

    // MARK: - Utils Functions

    func userResponse(forUser user: Customer.Public) -> UserResponse {
        return UserResponse(customerId: user.customerId, email: user.email)
    }

    func authToken(forUserToken token: UserToken) -> AuthTokenResponse {
        return AuthTokenResponse(token: token.token)
    }

}
