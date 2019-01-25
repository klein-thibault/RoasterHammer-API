import Vapor

public final class GraphDatabaseProvider: Provider {

    public func register(_ services: inout Services) throws {
        let neo4jClient = try Neo4j()
        services.register(neo4jClient)
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        let neo4jClient = try container.make(Neo4j.self)
        let connectionResult = neo4jClient.client.connectSync()
        print(connectionResult)
        return .done(on: container)
    }

}
