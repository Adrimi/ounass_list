import Foundation

protocol HTTPClient {
    func get<T: Decodable>(path: String) async throws -> T
}
