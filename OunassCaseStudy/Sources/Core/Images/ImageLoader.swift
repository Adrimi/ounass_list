import UIKit

protocol ImageLoader {
    func loadImage(from url: URL) async throws -> UIImage
}
