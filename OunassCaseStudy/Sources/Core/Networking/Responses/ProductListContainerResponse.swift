import Foundation

struct ProductListContainerResponse: Decodable {
    let styleColors: [ProductListItemResponse]
    let pagination: PaginationResponse
    let noFilterUrl: String?
}
