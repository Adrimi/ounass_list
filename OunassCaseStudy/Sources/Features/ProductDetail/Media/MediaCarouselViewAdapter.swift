import UIKit

final class MediaCarouselViewAdapter {
    private typealias ImagePresentationAdapter = LoadResourcePresentationAdapter<UIImage, WeakRefVirtualProxy<MediaCarouselCellController>>

    private weak var view: MediaCarouselView?
    private let imageLoader: ImageLoader
    private var currentMedia: [MediaAsset: CellController] = [:]

    init(view: MediaCarouselView, imageLoader: ImageLoader) {
        self.view = view
        self.imageLoader = imageLoader
    }

    func display(_ media: [MediaAsset]) {
        guard let view else { return }

        let cellControllers = media.map { asset in
            if let controller = currentMedia[asset] {
                return controller
            }

            let adapter = ImagePresentationAdapter(loader: { [imageLoader] in
                try await imageLoader.loadImage(from: asset.url)
            })

            let cellController = MediaCarouselCellController(imageDelegate: adapter)

            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(cellController),
                loadingView: WeakRefVirtualProxy(cellController),
                errorView: WeakRefVirtualProxy(cellController)
            )

            let controller = CellController(id: asset, cellController)
            currentMedia[asset] = controller
            return controller
        }

        currentMedia = currentMedia.filter { media.contains($0.key) }
        view.display(cellControllers, pageCount: media.count)
    }
}
