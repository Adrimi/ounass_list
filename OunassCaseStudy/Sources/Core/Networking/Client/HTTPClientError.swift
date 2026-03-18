import Foundation

enum HTTPClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server response could not be read."
        case .requestFailed(let statusCode):
            return "The server returned status code \(statusCode)."
        }
    }
}
