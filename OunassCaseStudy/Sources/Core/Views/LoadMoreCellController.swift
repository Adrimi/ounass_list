import UIKit

final class LoadMoreCellController: NSObject {
    static let reuseIdentifier = "LoadMoreCell"

    private var isLoading = false
    private var message: String?
    private weak var cell: LoadMoreCell?
    private weak var collectionView: UICollectionView?
    private let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    private func reloadIfNeeded() {
        guard !isLoading else { return }
        callback()
    }
}

extension LoadMoreCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadMoreCellController.reuseIdentifier, for: indexPath) as! LoadMoreCell
        cell.isLoading = isLoading
        cell.message = message
        self.cell = cell
        self.collectionView = collectionView
        return cell
    }
}

extension LoadMoreCellController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionView = collectionView
        reloadIfNeeded()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.cell = nil
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
}

extension LoadMoreCellController: CellSizeProvider {
    func size(in bounds: CGRect) -> CGSize {
        CGSize(width: max(0, bounds.width - 32), height: message == nil ? 60 : 84)
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        isLoading = viewModel.isLoading
        cell?.isLoading = isLoading
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

extension LoadMoreCellController: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        message = viewModel.message
        cell?.message = message
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}
