import UIKit

protocol ImageLoader: AnyObject {
    func loadImage(from url: URL) async throws -> UIImage
}

final class RemoteImageLoader: ImageLoader {
    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()
    private let logger = Logger(category: "Images")

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadImage(from url: URL) async throws -> UIImage {
        let cacheKey = url as NSURL
        if let cachedImage = cache.object(forKey: cacheKey) {
            logger.debug("cache hit: \(url.absoluteString)")
            return cachedImage
        }

        logger.debug("→ \(url.absoluteString)")
        let (data, _) = try await session.data(from: url)

        guard let image = UIImage(data: data) else {
            logger.error("failed to decode image from \(url.absoluteString)")
            throw HTTPClientError.invalidResponse
        }

        cache.setObject(image, forKey: cacheKey)
        return image
    }
}
