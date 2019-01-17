import Vapor
import FluentPostgreSQL

final class DetachmentController {

    func createDetachment(_ req: Request) throws -> Future<Detachment> {
        return try req.content.decode(Detachment.self).flatMap(to: Detachment.self, { detachment in
            return detachment.save(on: req).flatMap(to: Detachment.self, { detachment in
                return UnitRole.query(on: req).all().then({ unitRoles in
                    var futures: [Future<DetachmentUnit>] = []
                    for unitRole in unitRoles {
                        futures.append(detachment.unitRoles.attach(unitRole, on: req))
                    }

                    return futures.flatten(on: req).then({ _ in
                        return req.future(detachment)
                    })
                })
            })
        })
    }

    func detachments(_ req: Request) throws -> Future<[Detachment]> {
        return Detachment.query(on: req).all()
    }

    func addDetachmentToArmy(_ req: Request) throws -> Future<Army> {
        _ = try req.requireAuthenticated(Customer.self)
        let armyId = try req.parameters.next(Int.self)

        return try req.content.decode(AddDetachmentToArmyRequest.self)
            .flatMap(to: Detachment.self, { request in
                return Detachment.find(request.detachmentId, on: req).unwrap(or: RoasterHammerError.detachmentIsMissing)
            })
            .flatMap(to: Army.self, { detachment in
                return Army.find(armyId, on: req).unwrap(or: RoasterHammerError.armyIsMissing).then({ army in
                    return army.detachments.attach(detachment, on: req).then({ _ in
                        return req.future(army)
                    })
                })
            })
    }

}
