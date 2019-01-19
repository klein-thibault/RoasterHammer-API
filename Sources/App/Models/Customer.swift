import Vapor
import FluentPostgreSQL
import Authentication

final class Customer: PostgreSQLModel {
    var id: Int?
    var customerId: String
    var email: String
    var password: String
    var tokens: Children<Customer, UserToken> {
        return children(\.userID)
    }
    var games: Siblings<Customer, Game, UserGame> {
        return siblings()
    }

    init(id: Int? = nil,
         customerId: String,
         email: String,
         password: String) {
        self.id = id
        self.customerId = customerId
        self.email = email
        self.password = password
    }

    final class Public: Content {
        var customerId: String
        var email: String

        init(customerId: String, email: String) {
            self.customerId = customerId
            self.email = email
        }
    }
}

extension Customer: Content { }
extension Customer: PostgreSQLMigration { }

extension Customer {
    func convertToPublic() -> Customer.Public {
        return Customer.Public(customerId: customerId, email: email)
    }
}

extension Future where T: Customer {
    func convertToPublic() -> Future<Customer.Public> {
        return self.map(to: Customer.Public.self, { user in
            return user.convertToPublic()
        })
    }
}

extension Customer: BasicAuthenticatable {
    static var usernameKey: UsernameKey = \.email
    static var passwordKey: PasswordKey = \.password
}

extension Customer: TokenAuthenticatable {
    typealias TokenType = UserToken
}
