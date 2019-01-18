import Vapor
import FluentPostgreSQL

final class Characteristics: PostgreSQLModel {
    var id: Int?
    var movement: String
    var weaponSkill: String
    var balisticSkill: String
    var strength: String
    var toughness: String
    var wounds: String
    var attacks: String
    var leadership: String
    var save: String
    var unitId: Int

    var unit: Parent<Characteristics, Unit> {
        return parent(\.unitId)
    }

    init(movement: String,
         weaponSkill: String,
         balisticSkill: String,
         strength: String,
         toughness: String,
         wounds: String,
         attacks: String,
         leadership: String,
         save: String,
         unitId: Int) {
        self.movement = movement
        self.weaponSkill = weaponSkill
        self.balisticSkill = balisticSkill
        self.strength = strength
        self.toughness = toughness
        self.wounds = wounds
        self.attacks = attacks
        self.leadership = leadership
        self.save = save
        self.unitId = unitId
    }

}

extension Characteristics: Content { }
extension Characteristics: PostgreSQLMigration { }
