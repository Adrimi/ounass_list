#if DEBUG
import UIKit

struct FakeImageLoader: ImageLoader {
    func loadImage(from url: URL) async throws -> UIImage {
        .make(withColor: .systemRed)
    }
}
#endif
