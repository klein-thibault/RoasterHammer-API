import Vapor
import FluentPostgreSQL
import Theo

final class QAController {

    func testGraphDatabase(_ req: Request) throws -> Future<HTTPStatus> {
        let graphClient = try req.sharedContainer.make(Neo4j.self)
        graphClient.client.connectSync()

        let node = Node(label: "User", properties: ["email": "test@test.com"])
        let promise = req.eventLoop.newPromise(HTTPStatus.self)

        graphClient.client.createNode(node: node) { (result) in
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
