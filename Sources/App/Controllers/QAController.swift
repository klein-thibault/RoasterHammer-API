import Vapor
import FluentPostgreSQL
import Theo

final class QAController {

    func addNodeQA(_ req: Request) throws -> Future<HTTPStatus> {
        let graphClient = try req.sharedContainer.make(Neo4j.self)

        let node = Node(label: "User", properties: ["email": "test@test.com"])
        let promise = req.eventLoop.newPromise(HTTPStatus.self)

//        graphClient.client.createNode(node: node) { (result) in
//            switch result {
//            case let .failure(error):
//                promise.fail(error: error)
//            case .success(_):
//                promise.succeed(result: .ok)
//            }
//        }
//
//        return promise.futureResult

        _ = graphClient.client.createNodeSync(node: node)
        promise.succeed(result: .ok)

        return promise.futureResult
    }

    func getNodeQA(_ req: Request) throws -> Future<[String: String]> {
        let graphClient = try req.sharedContainer.make(Neo4j.self)
        let promise = req.eventLoop.newPromise([String: String].self)

        graphClient.client.nodesWith(label: "User") { (result) in
            switch result {
            case let .failure(error):
                promise.fail(error: error)
            case let .success(nodes):
                if let node = nodes.first {
                    promise.succeed(result: ["email": node.properties["email"] as! String])
                } else {
                    promise.succeed(result: ["email": "Empty"])
                }
            }
        }

        return promise.futureResult
    }

}
