import UIKit

final class ProductListViewController: UIViewController {
    private enum Section {
        case products
    }

    private let viewModel: ProductListViewModel
    private let imageLoader: ImageLoader
    private let collectionView: UICollectionView
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let paginationIndicator = UIActivityIndicatorView(style: .medium)
    private let placeholderView = ErrorPlaceholderView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    private var productsByID: [String: ProductSummary] = [:]
    private var orderedProductIDs: [String] = []
    private var prefetchTasks: [IndexPath: Task<Void, Never>] = [:]

    init(viewModel: ProductListViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureCollectionView()
        configureDataSource()
        bindViewModel()
        viewModel.loadInitialIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let columns: CGFloat = traitCollection.horizontalSizeClass == .compact ? 2 : 3
            let spacing = layout.minimumInteritemSpacing * (columns - 1)
            let insets = layout.sectionInset.left + layout.sectionInset.right
            let width = collectionView.bounds.width - spacing - insets
            let itemWidth = floor(width / columns)
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.92)
        }
    }

    private func configureView() {
        title = "Clothing"
        view.backgroundColor = .appBackground

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        paginationIndicator.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(placeholderView)
        view.addSubview(paginationIndicator)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            paginationIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paginationIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func configureCollectionView() {
        collectionView.register(ProductListCell.self, forCellWithReuseIdentifier: ProductListCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, identifier in
            guard
                let self,
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProductListCell.reuseIdentifier,
                    for: indexPath
                ) as? ProductListCell,
                let product = self.productsByID[identifier]
            else {
                return UICollectionViewCell()
            }

            cell.configure(with: product, imageLoader: self.imageLoader)
            return cell
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }

        placeholderView.onAction = { [weak self] in
            self?.viewModel.loadInitialIfNeeded()
        }
    }

    private func render(state: ProductListViewState) {
        productsByID = Dictionary(uniqueKeysWithValues: state.products.map { ($0.id, $0) })
        orderedProductIDs = state.products.map(\.id)
        applySnapshot(with: orderedProductIDs)

        if state.isInitialLoading && state.products.isEmpty {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        if state.isRefreshing == false {
            refreshControl.endRefreshing()
        }

        if state.isLoadingNextPage {
            paginationIndicator.startAnimating()
        } else {
            paginationIndicator.stopAnimating()
        }

        if state.products.isEmpty, let errorMessage = state.errorMessage, state.isInitialLoading == false {
            placeholderView.render(
                title: "Couldn’t load products",
                message: errorMessage,
                actionTitle: "Try Again"
            )
            placeholderView.isHidden = false
        } else if state.products.isEmpty, state.isInitialLoading == false {
            placeholderView.render(
                title: "No products found",
                message: "Pull to refresh or try again later.",
                actionTitle: "Refresh"
            )
            placeholderView.isHidden = false
        } else {
            placeholderView.isHidden = true
        }
    }

    private func applySnapshot(with identifiers: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.products])
        snapshot.appendItems(identifiers)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc private func handleRefresh() {
        viewModel.refresh()
    }
}

extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectProduct(at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard orderedProductIDs.indices.contains(indexPath.item) else {
            return
        }

        viewModel.loadNextPageIfNeeded(currentItemID: orderedProductIDs[indexPath.item])
    }
}

extension ProductListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard
                orderedProductIDs.indices.contains(indexPath.item),
                let product = productsByID[orderedProductIDs[indexPath.item]],
                let url = product.thumbnailURL
            else {
                return
            }

            prefetchTasks[indexPath] = Task {
                _ = try? await imageLoader.loadImage(from: url)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            prefetchTasks.removeValue(forKey: indexPath)?.cancel()
        }
    }
}

