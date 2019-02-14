//import Vapor
//import Theo
//
//final class Neo4j {
//    let client: BoltClient
//
//    init() throws {
//        self.client = try BoltClient(hostname: "localhost",
//                                     port: 7687,
//                                     username: "neo4j",
//                                     password: "password",
//                                     encrypted: false)
//    }
//}
//
//extension Neo4j: Service { }
//extension Neo4j: ServiceType {
//
//    static func makeService(for worker: Container) throws -> Neo4j {
//        return try Neo4j()
//    }
//
//
//}
