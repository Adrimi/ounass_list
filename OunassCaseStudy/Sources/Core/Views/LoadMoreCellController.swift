import UIKit

final class LoadMoreCell: UICollectionViewCell {
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isLoading: Bool = false {
        didSet { isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating() }
    }
}

final class LoadMoreCellController: NSObject {
    static let reuseIdentifier = "LoadMoreCell"

    private var isLoading = false
    private weak var cell: LoadMoreCell?
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadMoreCellController.reuseIdentifier, for: indexPath) as! LoadMoreCell
        cell.isLoading = isLoading
        self.cell = cell
        return cell
    }
}

extension LoadMoreCellController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        reloadIfNeeded()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.cell = nil
    }
}

extension LoadMoreCellController: CellSizeProvider {
    func size(in bounds: CGRect) -> CGSize {
        CGSize(width: bounds.width, height: 60)
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        isLoading = viewModel.isLoading
        cell?.isLoading = isLoading
    }
}

extension LoadMoreCellController: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {}
}
