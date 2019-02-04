import Vapor
import Leaf

struct WebsiteController {
    func indexHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("index")
    }
}
