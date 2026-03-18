import Foundation

struct ProductDetailData: Decodable {
    let styleColorId: String
    let slug: String
    let visibleSku: String
    let name: String
    let designerCategoryName: String
    let price: FlexibleDecimal
    let thumbnail: String?
    let media: [MediaResponse]?
    let amberPoints: Int?
    let colors: [ColorOptionResponse]?
    let selectedColor: ColorOptionResponse?
    let sizes: [SizeOptionResponse]?
    let outOfStock: Bool?
    let descriptionText: String?
}
