import Vapor

/// Creates an instance of Application. This is called from main.swift in the run target.
public func app(_ env: Environment) throws -> Application {
    var config = Config.default()
    var env = env
    var services = Services.default()
    let environmentConfiguration = registerEnvironmentConfiguration(for: env, services: &services)
    try configure(&config, &env, &services, environmentConfiguration)
    let app = try Application(config: config, environment: env, services: services)
    try boot(app)
    return app
}

public func registerEnvironmentConfiguration(for env: Environment, services: inout Services) -> EnvironmentConfiguration {
    if env.isRelease {
        return register(ProductionEnvironmentConfiguration(), services: &services)
    } else if env.isTesting {
        return register(TestingEnvironmentConfiguration(), services: &services)
    } else {
        return register(DevelopmentEnvironmentConfiguration(), services: &services)
    }
}

private func register<T: EnvironmentConfiguration>(_ configuration: T, services: inout Services) -> EnvironmentConfiguration {
    services.register(configuration, as: EnvironmentConfiguration.self)
    return configuration
}

extension Environment {
    var isTesting: Bool {
        return name == Environment.testing.name
    }
}
