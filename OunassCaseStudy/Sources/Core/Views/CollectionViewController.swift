import UIKit

final class CollectionViewController: UIViewController {
    var onRefresh: (() -> Void)?
    var onWillDisplayCell: ((IndexPath) -> Void)?

    private let layout: UICollectionViewLayout

    private(set) lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.prefetchDataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, CellController> = {
        UICollectionViewDiffableDataSource<Int, CellController>(collectionView: collectionView) { collectionView, indexPath, cellController in
            cellController.dataSource.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var errorBanner: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()

    init(layout: UICollectionViewLayout) {
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorBanner)
        collectionView.refreshControl = refreshControl
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @objc private func handleRefresh() {
        onRefresh?()
    }

    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellController(at: indexPath)?.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(at: indexPath)?.delegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
        onWillDisplayCell?(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(at: indexPath)?.delegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
}

extension CollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(at: indexPath)?.dataSourcePrefetching?.collectionView(collectionView, prefetchItemsAt: [indexPath])
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let prefetching = cellController(at: indexPath)?.dataSourcePrefetching else { return }
            prefetching.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
        }
    }
}

extension CollectionViewController: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
}

extension CollectionViewController: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        errorBanner.message = viewModel.message
    }
}
