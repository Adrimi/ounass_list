import UIKit

final class ProductListUIComposer {
    static func make(
        repository: ProductListRepositoryProtocol,
        imageLoader: ImageLoader,
        onSelection: @escaping (ProductSummary) -> Void
    ) -> ProductListViewController {
        let viewController = ProductListViewController()

        let adapter = LoadResourcePresentationAdapter<ProductListPage, ProductListViewAdapter>(
            loader: { try await repository.fetchFirstPage() }
        )

        let viewAdapter = ProductListViewAdapter(
            controller: viewController.collectionVC,
            imageLoader: imageLoader,
            selection: onSelection,
            loadMoreLoader: { path in try await repository.fetchPage(path: path) }
        )

        adapter.presenter = LoadResourcePresenter(
            resourceView: viewAdapter,
            loadingView: WeakRefVirtualProxy(viewController.collectionVC),
            errorView: WeakRefVirtualProxy(viewController.collectionVC)
        )

        viewController.onRefresh = { [weak viewAdapter] in
            viewAdapter?.reset()
            adapter.loadResource()
        }

        return viewController
    }
}
