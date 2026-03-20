import Foundation

protocol ProductListRepositoryProtocol {
    func fetchFirstPage() async throws -> ProductListPage
    func fetchPage(path: String) async throws -> ProductListPage
}
