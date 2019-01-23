import Vapor

public final class GraphDatabaseProvider: Provider {

    public func register(_ services: inout Services) throws {
        services.register(Neo4j.self)
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        let neo4j = try container.make(Neo4j.self)
        neo4j.client.connectSync()
        return .done(on: container)
    }

}
