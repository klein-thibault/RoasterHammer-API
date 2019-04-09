import Foundation
import Vapor
import FluentPostgreSQL

struct TestingEnvironmentConfiguration: EnvironmentConfiguration {
    var databaseConfiguration = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                         port: 5432,
                                                         username: "postgres",
                                                         database: "roasterhammer-testing",
                                                         password: "vPYZxUmZLxYMNiRrkrVX",
                                                         transport: .cleartext)

    func configure(_ services: inout Services) throws {
        // Nothing to configure
    }
}
