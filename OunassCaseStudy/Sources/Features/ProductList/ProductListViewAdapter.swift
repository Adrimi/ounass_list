import UIKit

final class ProductListViewAdapter: ResourceView {
    typealias ResourceViewModel = Paginated<ProductSummary>
    private typealias ImagePresentationAdapter = LoadResourcePresentationAdapter<UIImage, WeakRefVirtualProxy<ProductListCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<ProductSummary>, ProductListViewAdapter>

    private weak var controller: CollectionViewController?
    private let imageLoader: ImageLoader
    private let selection: (ProductSummary) -> Void
    private let currentProducts: [ProductSummary: CellController]

    init(
        currentProducts: [ProductSummary: CellController] = [:],
        controller: CollectionViewController,
        imageLoader: ImageLoader,
        selection: @escaping (ProductSummary) -> Void
    ) {
        self.currentProducts = currentProducts
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func display(_ page: Paginated<ProductSummary>) {
        guard let controller else { return }

        var currentProducts = self.currentProducts
        let productCells: [CellController] = page.items.map { product in
            if let controller = currentProducts[product] {
                return controller
            }

            let imageDelegate = product.thumbnailURL.map { url in
                makeImagePresentationAdapter(for: url)
            }

            let view = ProductListCellController(
                product: product,
                imageDelegate: imageDelegate,
                selection: { [selection] in selection(product) }
            )

            imageDelegate?.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view)
            )

            let controller = CellController(id: product, view)
            currentProducts[product] = controller
            return controller
        }

        guard let loadMore = page.loadMore else {
            controller.display(productCells)
            return
        }

        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMore)
        let loadMoreCellController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)

        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: ProductListViewAdapter(
                currentProducts: currentProducts,
                controller: controller,
                imageLoader: imageLoader,
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(loadMoreCellController),
            errorView: WeakRefVirtualProxy(loadMoreCellController)
        )

        controller.display(productCells, [CellController(id: UUID(), loadMoreCellController)])
    }

    private func makeImagePresentationAdapter(for url: URL) -> ImagePresentationAdapter {
        ImagePresentationAdapter(loader: { [imageLoader] in
            try await imageLoader.loadImage(from: url)
        })
    }
}
