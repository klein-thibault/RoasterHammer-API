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

    func unitsHandler(_ req: Request) throws -> Future<View> {
        let armyId = try req.parameters.next(Int.self)
        return UnitController()
            .getUnits(armyId: armyId, conn: req)
            .flatMap(to: View.self, { units in
            let context = UnitsContext(title: "Units", units: units)
            return try req.view().render("units", context)
        })
    }

}

struct IndexContext: Encodable {
    let title: String
    let armies: [ArmyResponse]
}

struct UnitsContext: Encodable {
    let title: String
    let units: [UnitResponse]
}
