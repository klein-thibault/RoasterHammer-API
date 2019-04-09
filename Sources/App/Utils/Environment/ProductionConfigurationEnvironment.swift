import Foundation
import Vapor
import FluentPostgreSQL

struct ProductionEnvironmentConfiguration: EnvironmentConfiguration {
    var databaseConfiguration: PostgreSQLDatabaseConfig

    init() {
        let databaseURL = Environment.get("DATABASE_URL")!
        databaseConfiguration = PostgreSQLDatabaseConfig(url: databaseURL)!
    }

    func configure(_ services: inout Services) throws {
        // Nothing to configure
    }
}
