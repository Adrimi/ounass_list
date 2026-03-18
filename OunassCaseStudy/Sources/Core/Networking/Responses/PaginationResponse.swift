import Foundation

struct PaginationResponse: Decodable {
    let totalItems: Int?
    let currentSet: Int?
    let viewSize: Int?
    let nextPage: PaginationLinkResponse?
}
