import FluentPostgreSQL

struct PopulateUnitTypeData: PostgreSQLMigration {
    static let unitTypes = [
        "HQ",
        "Troop",
        "Elite",
        "Fast Attack",
        "Heavy Support",
        "Lord of War"
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
