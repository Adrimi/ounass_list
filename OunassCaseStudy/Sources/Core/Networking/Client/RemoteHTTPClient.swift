import Foundation
import WebKit

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

@MainActor
private final class WKWebFetcher: NSObject, WKNavigationDelegate {
    private static let shared = WKWebFetcher()

    private let webView: WKWebView
    private var continuation: CheckedContinuation<String, Error>?

    private override init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        webView.navigationDelegate = self
    }

    static func fetch(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                shared.start(url: url, continuation: continuation)
            }
        }
    }

    private func start(url: URL, continuation: CheckedContinuation<String, Error>) {
        self.continuation = continuation
        webView.load(URLRequest(url: url))
    }

    private func finish(_ result: Result<String, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerText") { [weak self] result, error in
            if let error {
                self?.finish(.failure(error))
                return
            }
            guard let text = result as? String else {
                self?.finish(.failure(HTTPClientError.invalidResponse))
                return
            }
            let trimmed = text.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("{") || trimmed.hasPrefix("[") {
                self?.finish(.success(trimmed))
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finish(.failure(error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        finish(.failure(error))
    }
}
