import Foundation
import WebKit

@MainActor
final class WKWebFetcher: NSObject, WKNavigationDelegate {
    private let webView: WKWebView
    private var continuation: CheckedContinuation<String, Error>?
    private var didResumeContinuation = false

    private override init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        webView.navigationDelegate = self
    }

    static func fetch(url: URL) async throws -> String {
        let fetcher = WKWebFetcher()

        return try await withTaskCancellationHandler {
            try await fetcher.fetch(url: url)
        } onCancel: {
            Task { @MainActor in
                fetcher.cancel()
            }
        }
    }

    private func fetch(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            webView.load(URLRequest(url: url))
        }
    }

    private func cancel() {
        webView.stopLoading()
        finish(.failure(CancellationError()))
    }

    private func finish(_ result: Result<String, Error>) {
        guard !didResumeContinuation, let continuation else { return }
        didResumeContinuation = true
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

            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("{") || trimmed.hasPrefix("[") else {
                self?.finish(.failure(HTTPClientError.invalidResponse))
                return
            }

            self?.finish(.success(trimmed))
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finish(.failure(error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        finish(.failure(error))
    }
}
