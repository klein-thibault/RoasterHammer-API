import Vapor

struct AddWeaponToModelRequest: Content {
    let minQuantity: Int
    let maxQuantity: Int
}
