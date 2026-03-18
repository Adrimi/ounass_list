import Foundation

final class ProductDetailRepository: ProductDetailRepositoryProtocol {
    private let apiClient: any HTTPClient

    init(apiClient: any HTTPClient = RemoteHTTPClient()) {
        self.apiClient = apiClient
    }

    func fetchDetail(slug: String) async throws -> ProductDetail {
        let response: ProductDetailResponse = try await apiClient.get(path: "/\(slug).html")
        return response.toDomain()
    }
}
