import Foundation

struct SizeOptionResponse: Decodable {
    let sku: String
    let sizeCodeId: Int
    let sizeCode: String
    let price: FlexibleDecimal?
    let amberPoints: Int?
    let disabled: Bool?
    let stock: Int?
}
