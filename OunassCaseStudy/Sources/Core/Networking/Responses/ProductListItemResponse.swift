import Foundation

struct ProductListItemResponse: Decodable {
    let styleColorId: String
    let slug: String
    let designerCategoryName: String
    let thumbnail: String?
    let name: String
    let price: FlexibleDecimal
}
