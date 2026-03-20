import Foundation

final class RemoteHTTPClient: HTTPClient {
    private let decoder: JSONDecoder
    private let logger = Logger(category: "Network")

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func get<T: Decodable>(path: String) async throws -> T {
        guard let url = OunassURLBuilder.apiURL(path: path) else {
            logger.error("✗ invalid URL for path: \(path)")
            throw HTTPClientError.invalidURL
        }

        let startTime = Date()
        logger.debug("→ GET \(url.absoluteString)")

        let jsonString = try await WKWebFetcher.fetch(url: url)

        let ms = Int(Date().timeIntervalSince(startTime) * 1000)
        let bytes = jsonString.utf8.count
        logger.debug("← \(url.absoluteString) (\(ms)ms) — \(bytes) bytes")

        guard let data = jsonString.data(using: .utf8) else {
            throw HTTPClientError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }
}
