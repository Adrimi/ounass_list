import UIKit

final class ProductListViewAdapter: ResourceView {
    typealias ResourceViewModel = ProductListPage

    private weak var controller: CollectionViewController?
    private let imageLoader: ImageLoader
    private let selection: (ProductSummary) -> Void
    private let loadMoreLoader: ((String) async throws -> ProductListPage)?

    private var existingControllers: [String: ProductListCellController]
    private var accumulatedProducts: [ProductSummary]

    private(set) var currentPagination: PaginationInfo?
    var productCount: Int { accumulatedProducts.count }

    init(
        existingControllers: [String: ProductListCellController] = [:],
        accumulatedProducts: [ProductSummary] = [],
        controller: CollectionViewController,
        imageLoader: ImageLoader,
        selection: @escaping (ProductSummary) -> Void,
        loadMoreLoader: ((String) async throws -> ProductListPage)?
    ) {
        self.existingControllers = existingControllers
        self.accumulatedProducts = accumulatedProducts
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
        self.loadMoreLoader = loadMoreLoader
    }

    func reset() {
        existingControllers = [:]
        accumulatedProducts = []
        currentPagination = nil
    }

    func display(_ page: ProductListPage) {
        currentPagination = page.pagination
        let existingIDs = Set(accumulatedProducts.map(\.id))
        let newProducts = page.products.filter { !existingIDs.contains($0.id) }
        accumulatedProducts.append(contentsOf: newProducts)

        let productCells: [CellController] = accumulatedProducts.map { product in
            let cc = existingControllers[product.id] ?? ProductListCellController(
                product: product,
                imageLoader: imageLoader,
                selection: { [weak self] in self?.selection(product) }
            )
            existingControllers[product.id] = cc
            return CellController(id: product.id, cc)
        }

        guard let nextPath = page.pagination.nextPagePath, let controller else {
            controller?.display(productCells)
            return
        }

        let loadMoreAdapter = LoadResourcePresentationAdapter<ProductListPage, ProductListViewAdapter>(
            loader: { [loadMoreLoader] in
                guard let loadMoreLoader else { throw CancellationError() }
                return try await loadMoreLoader(nextPath)
            }
        )
        let loadMoreCell = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: ProductListViewAdapter(
                existingControllers: existingControllers,
                accumulatedProducts: accumulatedProducts,
                controller: controller,
                imageLoader: imageLoader,
                selection: selection,
                loadMoreLoader: loadMoreLoader
            ),
            loadingView: WeakRefVirtualProxy(loadMoreCell),
            errorView: WeakRefVirtualProxy(loadMoreCell)
        )

        controller.display(productCells + [CellController(id: UUID(), loadMoreCell)])
    }
}
