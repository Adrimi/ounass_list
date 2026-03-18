import Foundation

enum OunassURLBuilder {
    private static let siteBaseURL = URL(string: "https://www.ounass.ae")!
    private static let apiBaseURL = URL(string: "https://www.ounass.ae/api/v2")!
    private static let mediaBaseURL = URL(string: "https://ounass-ae.atgcdn.ae/pub/media/catalog/product")!

    private static func resolveURL(base: URL, path: String) -> URL? {
        if let absoluteURL = URL(string: path), absoluteURL.scheme != nil {
            return absoluteURL
        }
        if path.hasPrefix("//") {
            return URL(string: "https:\(path)")
        }
        let separator = path.hasPrefix("/") ? "" : "/"
        return URL(string: base.absoluteString + separator + path)
    }

    static func apiURL(path: String) -> URL? {
        let normalizedPath: String
        if path.hasPrefix("/api/v2/") {
            normalizedPath = String(path.dropFirst("/api/v2".count))
        } else {
            normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        }
        return resolveURL(base: apiBaseURL, path: normalizedPath)
    }

    static func websiteURL(path: String?) -> URL? {
        guard let path, path.isEmpty == false else { return nil }
        return resolveURL(base: siteBaseURL, path: path)
    }

    static func imageURL(path: String?) -> URL? {
        guard let path, path.isEmpty == false else { return nil }
        return resolveURL(base: mediaBaseURL, path: path)
    }

    static func slug(from urlString: String?) -> String? {
        guard let urlString, urlString.isEmpty == false else {
            return nil
        }

        let trimmed = urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.hasSuffix(".html") ? String(trimmed.dropLast(".html".count)) : trimmed
    }
}
