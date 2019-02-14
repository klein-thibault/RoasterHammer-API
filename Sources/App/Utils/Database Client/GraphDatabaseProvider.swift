//import Vapor
//
//public final class GraphDatabaseProvider: Provider {
//
//    public func register(_ services: inout Services) throws {
//        let neo4jClient = try Neo4j()
//        services.register(neo4jClient)
//    }
//
//    public func didBoot(_ container: Container) throws -> Future<Void> {
//        let neo4jClient = try container.make(Neo4j.self)
//        let connectionResult = neo4jClient.client.connectSync()
//        print("==============")
//        print("Connection to Neo4j: \(connectionResult)")
//        print("==============")
//        return .done(on: container)
//    }
//
//}
