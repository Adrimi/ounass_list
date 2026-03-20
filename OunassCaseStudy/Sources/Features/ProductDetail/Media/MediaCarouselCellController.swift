import UIKit

final class MediaCarouselCellController: NSObject {
    typealias ResourceViewModel = UIImage

    private let imageDelegate: ImageCellControllerDelegate
    private weak var cell: MediaCarouselCell?

    init(imageDelegate: ImageCellControllerDelegate) {
        self.imageDelegate = imageDelegate
    }
}

extension MediaCarouselCellController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCarouselCell.reuseIdentifier, for: indexPath) as! MediaCarouselCell
        self.cell = cell
        cell.prepareForDisplay()
        cell.onRetry = { [weak self] in
            self?.imageDelegate.didRequestImage()
        }
        imageDelegate.didRequestImage()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelImageLoad()
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        imageDelegate.didRequestImage()
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelImageLoad()
    }

    private func cancelImageLoad() {
        releaseCellForReuse()
        imageDelegate.didCancelImageRequest()
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}

extension MediaCarouselCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    func display(_ viewModel: UIImage) {
        cell?.imageView.setImageAnimated(viewModel)
    }

    func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.imageContainer.isShimmering = viewModel.isLoading
    }

    func display(_ viewModel: ResourceErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
}
