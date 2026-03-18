import UIKit

final class ProductListUIComposer {
    static func make(
        repository: ProductListRepositoryProtocol,
        imageLoader: ImageLoader,
        onSelection: @escaping (ProductSummary) -> Void
    ) -> ProductListViewController {
        let vc = ProductListViewController()

        let adapter = LoadResourcePresentationAdapter<ProductListPage, ProductListViewAdapter>(
            loader: { try await repository.fetchFirstPage() }
        )

        let viewAdapter = ProductListViewAdapter(
            controller: vc.collectionVC,
            imageLoader: imageLoader,
            selection: onSelection,
            loadMoreLoader: { path in try await repository.fetchPage(path: path) }
        )

        adapter.presenter = LoadResourcePresenter(
            resourceView: viewAdapter,
            loadingView: WeakRefVirtualProxy(vc.collectionVC),
            errorView: WeakRefVirtualProxy(vc.collectionVC)
        )

        vc.onRefresh = { [weak viewAdapter] in
            viewAdapter?.reset()
            adapter.loadResource()
        }

        return vc
    }
}
