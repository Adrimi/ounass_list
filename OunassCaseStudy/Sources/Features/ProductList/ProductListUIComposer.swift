import UIKit

final class ProductListUIComposer {
    private typealias ProductPageLoader = LoadResourcePresentationAdapter<Paginated<ProductSummary>, ProductListViewAdapter>

    static func make(
        repository: ProductListRepositoryProtocol,
        imageLoader: ImageLoader,
        onSelection: @escaping (ProductSummary) -> Void
    ) -> ProductListViewController {
        let viewController = ProductListViewController()

        let adapter = ProductPageLoader(
            loader: { try await makeFirstPage(repository: repository) }
        )

        let viewAdapter = ProductListViewAdapter(
            controller: viewController.collectionVC,
            imageLoader: imageLoader,
            selection: onSelection
        )

        adapter.presenter = LoadResourcePresenter(
            resourceView: viewAdapter,
            loadingView: WeakRefVirtualProxy(viewController.collectionVC),
            errorView: WeakRefVirtualProxy(viewController.collectionVC)
        )

        viewController.onRefresh = adapter.loadResource

        return viewController
    }

    private static func makeFirstPage(repository: ProductListRepositoryProtocol) async throws -> Paginated<ProductSummary> {
        let page = try await repository.fetchFirstPage()
        return makePage(from: page, accumulatedProducts: [], repository: repository)
    }

    private static func makePage(
        from page: ProductListPage,
        accumulatedProducts: [ProductSummary],
        repository: ProductListRepositoryProtocol
    ) -> Paginated<ProductSummary> {
        let products = merge(accumulatedProducts, with: page.products)

        return Paginated(
            items: products,
            loadMore: page.nextPagePath.map { nextPath in
                {
                    let nextPage = try await repository.fetchPage(path: nextPath)
                    return makePage(from: nextPage, accumulatedProducts: products, repository: repository)
                }
            }
        )
    }

    private static func merge(_ accumulatedProducts: [ProductSummary], with newProducts: [ProductSummary]) -> [ProductSummary] {
        let existingIDs = Set(accumulatedProducts.map(\.id))
        return accumulatedProducts + newProducts.filter { !existingIDs.contains($0.id) }
    }
}
