import UIKit

final class ProductListViewController: UIViewController {
    private let repository: ProductListRepositoryProtocol
    private let imageLoader: ImageLoader
    private let onProductSelection: ((ProductSummary) -> Void)?

    private var collectionVC: CollectionViewController!
    private var viewAdapter: ProductListViewAdapter!
    private var initialLoadAdapter: LoadResourcePresentationAdapter<ProductListPage, ProductListViewAdapter>!
    private let paginationIndicator = UIActivityIndicatorView(style: .medium)
    private var isLoadingMore = false
    private var requestedPagePaths = Set<String>()

    init(
        repository: ProductListRepositoryProtocol,
        imageLoader: ImageLoader,
        onProductSelection: ((ProductSummary) -> Void)?
    ) {
        self.repository = repository
        self.imageLoader = imageLoader
        self.onProductSelection = onProductSelection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ProductListPresenter.title
        view.backgroundColor = .appBackground
        setupCollectionViewController()
        setupPaginationIndicator()
        setupInitialLoad()
        initialLoadAdapter.loadResource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFlowLayoutItemSize()
    }

    private func setupCollectionViewController() {
        let layout = makeFlowLayout()
        collectionVC = CollectionViewController(layout: layout)

        addChild(collectionVC)
        collectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionVC.view)
        NSLayoutConstraint.activate([
            collectionVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionVC.didMove(toParent: self)

        collectionVC.collectionView.register(ProductListCell.self, forCellWithReuseIdentifier: ProductListCell.reuseIdentifier)

        viewAdapter = ProductListViewAdapter(
            controller: collectionVC,
            imageLoader: imageLoader,
            selection: { [weak self] product in self?.onProductSelection?(product) }
        )

        collectionVC.onRefresh = { [weak self] in self?.handleRefresh() }
        collectionVC.onWillDisplayCell = { [weak self] indexPath in self?.loadNextPageIfNeeded(at: indexPath) }
    }

    private func setupPaginationIndicator() {
        paginationIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paginationIndicator)
        NSLayoutConstraint.activate([
            paginationIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paginationIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func setupInitialLoad() {
        initialLoadAdapter = LoadResourcePresentationAdapter(
            loader: { [weak self] in
                guard let self else { throw CancellationError() }
                return try await self.repository.fetchFirstPage()
            }
        )
        let presenter = LoadResourcePresenter(
            resourceView: viewAdapter,
            loadingView: WeakRefVirtualProxy(collectionVC),
            errorView: WeakRefVirtualProxy(collectionVC)
        )
        initialLoadAdapter.presenter = presenter
    }

    private func handleRefresh() {
        viewAdapter.reset()
        requestedPagePaths.removeAll()

        Task { @MainActor [weak self] in
            guard let self else { return }
            self.collectionVC.display(ResourceErrorViewModel.noError)
            do {
                let page = try await self.repository.refresh()
                self.viewAdapter.display(page)
            } catch {
                self.collectionVC.display(ResourceErrorViewModel(message: error.localizedDescription))
            }
            self.collectionVC.display(ResourceLoadingViewModel(isLoading: false))
        }
    }

    private func loadNextPageIfNeeded(at indexPath: IndexPath) {
        guard
            !isLoadingMore,
            let nextPagePath = viewAdapter.currentPagination?.nextPagePath,
            !requestedPagePaths.contains(nextPagePath),
            indexPath.item >= max(viewAdapter.productCount - 6, 0)
        else { return }

        requestedPagePaths.insert(nextPagePath)
        isLoadingMore = true
        paginationIndicator.startAnimating()

        Task { @MainActor [weak self] in
            guard let self else { return }
            defer {
                self.isLoadingMore = false
                self.paginationIndicator.stopAnimating()
            }
            do {
                let page = try await self.repository.fetchPage(path: nextPagePath)
                self.viewAdapter.display(page)
            } catch {
                self.requestedPagePaths.remove(nextPagePath)
            }
        }
    }

    private func makeFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        return layout
    }

    private func updateFlowLayoutItemSize() {
        guard let layout = collectionVC?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let columns: CGFloat = traitCollection.horizontalSizeClass == .compact ? 2 : 3
        let spacing = layout.minimumInteritemSpacing * (columns - 1)
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let width = view.bounds.width - spacing - insets
        let itemWidth = floor(width / columns)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.92)
    }
}

// MARK: - ProductListViewAdapter

final class ProductListViewAdapter: ResourceView {
    typealias ResourceViewModel = ProductListPage

    private weak var controller: CollectionViewController?
    private let imageLoader: ImageLoader
    private let selection: (ProductSummary) -> Void

    private var products: [ProductSummary] = []
    private var existingControllers: [String: ProductListCellController] = [:]
    private(set) var currentPagination: PaginationInfo?

    var productCount: Int { products.count }

    init(controller: CollectionViewController, imageLoader: ImageLoader, selection: @escaping (ProductSummary) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func reset() {
        products = []
        existingControllers = [:]
        currentPagination = nil
    }

    func display(_ page: ProductListPage) {
        currentPagination = page.pagination

        let existingIDs = Set(products.map(\.id))
        let newProducts = page.products.filter { !existingIDs.contains($0.id) }
        products.append(contentsOf: newProducts)

        let cellControllers = products.map { product -> CellController in
            let existing = existingControllers[product.id]
            let cellController = existing ?? ProductListCellController(
                product: product,
                imageLoader: imageLoader,
                selection: { [weak self] in self?.selection(product) }
            )
            existingControllers[product.id] = cellController
            return CellController(id: product.id, cellController)
        }

        controller?.display(cellControllers)
    }
}
