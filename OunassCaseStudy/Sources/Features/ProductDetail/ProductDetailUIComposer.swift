import UIKit

@MainActor
final class ProductDetailUIComposer {
    private typealias DetailLoader = LoadResourcePresentationAdapter<ProductDetail, ProductDetailPresentationAdapter>

    private init() {}

    static func make(
        slug: String,
        repository: ProductDetailRepositoryProtocol,
        imageLoader: ImageLoader
    ) -> ProductDetailViewController {
        let viewController = ProductDetailViewController(imageLoader: imageLoader)
        let presentationAdapter = ProductDetailPresentationAdapter(requestedSlug: slug, view: viewController)
        let detailLoader = DetailLoader(loader: {
            let requestedSlug = await MainActor.run { [weak presentationAdapter] in
                presentationAdapter?.requestedSlug
            }

            guard let requestedSlug else {
                throw CancellationError()
            }

            return try await repository.fetchDetail(slug: requestedSlug)
        })

        presentationAdapter.loadRequestedDetail = { [weak detailLoader] in
            detailLoader?.loadResource()
        }

        detailLoader.presenter = LoadResourcePresenter(
            resourceView: presentationAdapter,
            loadingView: WeakRefVirtualProxy(viewController),
            errorView: WeakRefVirtualProxy(viewController)
        )

        viewController.onLoad = { [presentationAdapter, detailLoader] in
            _ = detailLoader
            presentationAdapter.didRequestLoad()
        }
        viewController.onRetry = { [presentationAdapter, detailLoader] in
            _ = detailLoader
            presentationAdapter.didRequestRetry()
        }
        viewController.onOptionSelection = { [presentationAdapter, detailLoader] selection in
            _ = detailLoader
            presentationAdapter.didSelectOption(selection)
        }

        return viewController
    }
}
