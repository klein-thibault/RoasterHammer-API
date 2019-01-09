@testable import App
import FluentPostgreSQL
import Crypto

extension Customer {
    static func create(email: String = UUID().uuidString,
                       on connection: DatabaseConnectable) throws -> Customer {
        let password = try BCrypt.hash("password")
        let customer = Customer(customerId: UUID().uuidString,
                                email: email,
                                password: password)
        return try customer.save(on: connection).wait()
    }
}
