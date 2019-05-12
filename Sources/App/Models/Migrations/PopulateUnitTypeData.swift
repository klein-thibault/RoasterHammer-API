import FluentPostgreSQL

struct PopulateUnitTypeData: PostgreSQLMigration {
    static let unitTypes = [
        Constants.RoleName.hq,
        Constants.RoleName.troop,
        Constants.RoleName.elite,
        Constants.RoleName.fastAttack,
        Constants.RoleName.heavySupport,
        Constants.RoleName.flyer,
        Constants.RoleName.dedicatedTransport,
        Constants.RoleName.lordOfWar
    ]

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let unitTypeFutures = unitTypes
            .map { UnitType(name: $0).save(on: conn) }
            .map(to: Void.self, on: conn) { _ in return }
        return Future<Void>.andAll([unitTypeFutures], eventLoop: conn.eventLoop)
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = unitTypes.map { name in
            return UnitType.query(on: conn).filter(\.name == name).delete()
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

}
