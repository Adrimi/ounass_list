import Foundation

protocol ProductDetailRepositoryProtocol {
    func fetchDetail(slug: String) async throws -> ProductDetail
}
