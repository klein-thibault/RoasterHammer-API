import Vapor
import FluentPostgreSQL
import Crypto

final class UserController {

    func createUser(_ req: Request) throws -> Future<Customer.Public> {
        return try req.content.decode(CreateUserRequest.self)
            .flatMap(to: Customer.Public.self, { request in
                let encryptedPassword = try BCrypt.hash(request.password)
                let customer = Customer(customerId: UUID().uuidString,
                                        email: request.email,
                                        password: encryptedPassword)
                return customer.save(on: req).convertToPublic()
            })
    }

    func loginUser(_ req: Request) throws -> Future<UserToken> {
        let customer = try req.requireAuthenticated(Customer.self)
        let token = try UserToken.generate(for: customer)
        return token.save(on: req)
    }

    func getUser(_ req: Request) throws -> Future<Customer.Public> {
        let customer = try req.requireAuthenticated(Customer.self)
        let promiseCustomer = req.eventLoop.newPromise(Customer.Public.self)
        promiseCustomer.succeed(result: customer.convertToPublic())
        return promiseCustomer.futureResult
    }

}
