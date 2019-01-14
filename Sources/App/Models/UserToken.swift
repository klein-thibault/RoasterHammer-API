//
//  UserToken.swift
//  App
//
//  Created by Thibault Klein on 1/9/19.
//

import Vapor
import FluentPostgreSQL
import Crypto
import Authentication

final class UserToken: PostgreSQLModel {
    var id: Int?
    var token: String
    var userID: Customer.ID

    init(token: String, userID: Customer.ID) {
        self.token = token
        self.userID = userID
    }

    var customer: Parent<UserToken, Customer> {
        return parent(\.userID)
    }

}

extension UserToken: Content { }
extension UserToken: PostgreSQLMigration { }

extension UserToken: Token {
    typealias UserType = Customer
    typealias UserIDType = Customer.ID

    static var tokenKey: WritableKeyPath<UserToken, String> {
        return \.token
    }

    static var userIDKey: WritableKeyPath<UserToken, Customer.ID> {
        return \UserToken.userID
    }
}

extension UserToken {
    static func generate(for customer: Customer) throws -> UserToken {
        let random = try CryptoRandom().generateData(count: 16)
        return try UserToken(token: random.base64EncodedString(), userID: customer.requireID())
    }
}

