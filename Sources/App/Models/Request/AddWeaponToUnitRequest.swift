import Vapor

struct AddWeaponToUnitRequest: Content {
    let minQuantity: Int
    let maxQuantity: Int
}
