import UIKit

final class ProductListCellController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    private let product: ProductSummary
    private let imageLoader: ImageLoader
    private let selection: () -> Void
    private var prefetchTask: Task<Void, Never>?

    init(product: ProductSummary, imageLoader: ImageLoader, selection: @escaping () -> Void) {
        self.product = product
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductListCell.reuseIdentifier, for: indexPath) as! ProductListCell
        cell.configure(with: product, imageLoader: imageLoader)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selection()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        prefetchTask?.cancel()
        prefetchTask = nil
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let url = product.thumbnailURL else { return }
        prefetchTask = Task {
            _ = try? await imageLoader.loadImage(from: url)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        prefetchTask?.cancel()
        prefetchTask = nil
    }
}
