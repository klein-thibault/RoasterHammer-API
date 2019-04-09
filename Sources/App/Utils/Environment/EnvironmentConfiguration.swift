import Vapor
import FluentPostgreSQL

/// Application environment configuration
///
/// - Source: https://losingfight.com/blog/2018/12/09/environment-configuration-in-vapor/
public protocol EnvironmentConfiguration: Service {
    var databaseConfiguration: PostgreSQLDatabaseConfig { get }

    func configure(_ services: inout Services) throws
}
