import Vapor
import Theo

final class GraphDatabaseClient {
    let client: BoltClient

    init() throws {
        self.client = try BoltClient(hostname: "localhost",
                                     port: 7687,
                                     username: "neo4j",
                                     password: "password",
                                     encrypted: false)
    }
}

extension GraphDatabaseClient: Service { }
extension GraphDatabaseClient: ServiceType {

    static func makeService(for worker: Container) throws -> GraphDatabaseClient {
        return try GraphDatabaseClient()
    }


}
