import Vapor
import Leaf

struct WebsiteController {
    func indexHandler(_ req: Request) throws -> Future<View> {
        let armyController = ArmyController()
        return try armyController.armies(req).flatMap(to: View.self, { armies in
            let context = IndexContext(title: "Homepage", armies: armies)
            return try req.view().render("index", context)
        })
    }
}

struct IndexContext: Encodable {
    let title: String
    let armies: [ArmyResponse]
}
