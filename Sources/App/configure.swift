import Vapor
import Leaf
import FluentPostgreSQL
import Authentication

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
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database
    let databaseConfiguration = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                         port: 5432,
                                                         username: "postgres",
                                                         database: "postgres",
                                                         password: "vPYZxUmZLxYMNiRrkrVX",
                                                         transport: .cleartext)
    let postgresql = PostgreSQLDatabase(config: databaseConfiguration)

    /// Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    // Configure templating framework for the website
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Configure migrations
    var migrations = MigrationConfig()
    NodeElementClosure.defaultDatabase = .psql
    GameRule.defaultDatabase = .psql
    RoasterRule.defaultDatabase = .psql
    UserGame.defaultDatabase = .psql
    ArmyRule.defaultDatabase = .psql
    RoasterDetachment.defaultDatabase = .psql
    UnitRule.defaultDatabase = .psql
    UnitRole.defaultDatabase = .psql
    ModelWeapon.defaultDatabase = .psql
    UnitKeyword.defaultDatabase = .psql
    FactionRule.defaultDatabase = .psql
    UnitModel.defaultDatabase = .psql
    SelectedUnit.defaultDatabase = .psql
    SelectedModel.defaultDatabase = .psql
    SelectedModelWeapon.defaultDatabase = .psql
    SelectedUnitModel.defaultDatabase = .psql
    migrations.add(model: Customer.self, database: .psql)
    migrations.add(model: UserToken.self, database: .psql)
    migrations.add(model: NodeElement.self, database: .psql)
    migrations.add(model: Game.self, database: .psql)
    migrations.add(model: Rule.self, database: .psql)
    migrations.add(model: Roaster.self, database: .psql)
    migrations.add(model: Army.self, database: .psql)
    migrations.add(model: Detachment.self, database: .psql)
    migrations.add(model: Role.self, database: .psql)
    migrations.add(model: Unit.self, database: .psql)
    migrations.add(model: Characteristics.self, database: .psql)
    migrations.add(model: Weapon.self, database: .psql)
    migrations.add(model: Keyword.self, database: .psql)
    migrations.add(model: UnitType.self, database: .psql)
    migrations.add(model: Faction.self, database: .psql)
    migrations.add(model: Model.self, database: .psql)
    migrations.add(migration: CreateNodeElementClosure.self, database: .psql)
    migrations.add(migration: CreateGameRule.self, database: .psql)
    migrations.add(migration: CreateRoasterRule.self, database: .psql)
    migrations.add(migration: CreateUserGame.self, database: .psql)
    migrations.add(migration: CreateArmyRule.self, database: .psql)
    migrations.add(migration: CreateRoasterDetachment.self, database: .psql)
    migrations.add(migration: CreateSelectedUnit.self, database: .psql)
    migrations.add(migration: CreateSelectedModel.self, database: .psql)
    migrations.add(migration: CreateSelectedUnitModel.self, database: .psql)
    migrations.add(migration: CreateSelectedModelWeapon.self, database: .psql)
    migrations.add(migration: CreateUnitRule.self, database: .psql)
    migrations.add(migration: CreateUnitRole.self, database: .psql)
    migrations.add(migration: CreateModelWeapon.self, database: .psql)
    migrations.add(migration: CreateUnitKeyword.self, database: .psql)
    migrations.add(migration: CreateFactionRule.self, database: .psql)
    migrations.add(migration: CreateUnitModel.self, database: .psql)
    migrations.add(migration: PopulateUnitTypeData.self, database: .psql)
    services.register(migrations)

    // Configure the command line tool to add Fluent commands like revert and migrate database
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    // Auth provider
    try services.register(AuthenticationProvider())

    // Graph database provider
//    try services.register(GraphDatabaseProvider())
}
