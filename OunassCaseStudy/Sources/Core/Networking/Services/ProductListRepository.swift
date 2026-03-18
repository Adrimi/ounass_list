import Foundation

final class ProductListRepository: ProductListRepositoryProtocol {
    private let apiClient: any HTTPClient

    init(apiClient: any HTTPClient = RemoteHTTPClient()) {
        self.apiClient = apiClient
    }

    func fetchFirstPage() async throws -> ProductListPage {
        try await fetchPage(path: "/women/clothing")
    }

    func fetchPage(path: String) async throws -> ProductListPage {
        let response: ProductListResponse = try await apiClient.get(path: path)
        return response.toDomain()
    }

    func refresh() async throws -> ProductListPage {
        try await fetchFirstPage()
    }
}
