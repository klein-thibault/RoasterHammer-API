import Vapor
import FluentPostgreSQL
import Theo

final class QAController {

    func testGraphDatabase(_ req: Request) throws -> Future<HTTPStatus> {
//        let graphClient = try req.sharedContainer.make(GraphDatabaseClient.self)
        let graphClient = try BoltClient(hostname: "localhost",
                                         port: 7687,
                                         username: "thibault",
                                         password: "password",
                                         encrypted: true)
        let node = Node(label: "User", properties: ["email": "test@test.com"])
        let promise = req.eventLoop.newPromise(HTTPStatus.self)

        graphClient.createNode(node: node) { (result) in
            switch result {
            case let .failure(error):
                promise.fail(error: error)
            case .success(_):
                promise.succeed(result: .ok)
            }
        }

        return promise.futureResult
    }

}
