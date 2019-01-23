import Vapor
import FluentPostgreSQL

final class SelectedUnit: PostgreSQLModel {
    var id: Int?
    var unitId: Int
    var roles: Siblings<SelectedUnit, Role, UnitRole> {
        return siblings()
    }
    var weapons: Siblings<SelectedUnit, Weapon, SelectedUnitWeapon> {
        return siblings()
    }

    init(unitId: Int) {
        self.unitId = unitId
    }
}

extension SelectedUnit: Content { }
extension SelectedUnit: PostgreSQLMigration { }
