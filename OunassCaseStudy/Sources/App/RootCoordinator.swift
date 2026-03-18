import UIKit

@MainActor
final class RootCoordinator {
    private let window: UIWindow
    private let appContainer: AppContainer
    private let navigationController = UINavigationController()

    init(window: UIWindow, appContainer: AppContainer) {
        self.window = window
        self.appContainer = appContainer
    }

    func start() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.view.backgroundColor = .systemBackground
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showProductList()
    }

    private func showProductList() {
        let viewModel = ProductListViewModel(repository: appContainer.productListRepository)
        viewModel.onProductSelection = { [weak self] product in
            self?.showProductDetail(slug: product.slug)
        }

        let viewController = ProductListViewController(
            viewModel: viewModel,
            imageLoader: appContainer.imageLoader
        )
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showProductDetail(slug: String) {
        let viewModel = ProductDetailViewModel(
            initialSlug: slug,
            repository: appContainer.productDetailRepository
        )
        let viewController = ProductDetailViewController(
            viewModel: viewModel,
            imageLoader: appContainer.imageLoader
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
