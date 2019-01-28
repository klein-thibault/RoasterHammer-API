import Vapor

struct AddUnitToDetachmentRequest: Content {
    let unitQuantity: Int
}
