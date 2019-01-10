import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database
    let config = PostgreSQLDatabaseConfig(hostname: "localhost",
                                          port: 5432,
                                          username: "postgres",
                                          database: "postgres",
                                          password: "vPYZxUmZLxYMNiRrkrVX",
                                          transport: .cleartext)
    let postgresql = PostgreSQLDatabase(config: config)

    /// Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    NodeElementClosure.defaultDatabase = .psql
    migrations.add(model: NodeElement.self, database: .psql)
    migrations.add(migration: CreateNodeElementClosure.self, database: .psql)
    services.register(migrations)

    // Configure the command line tool to add Fluent commands like revert and migrate database
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
