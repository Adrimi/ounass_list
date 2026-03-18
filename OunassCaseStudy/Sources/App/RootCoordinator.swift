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
        let viewController = ProductListUIComposer.make(
            repository: appContainer.productListRepository,
            imageLoader: appContainer.imageLoader,
            onSelection: { [weak self] product in
                self?.showProductDetail(slug: product.slug)
            }
        )
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showProductDetail(slug: String) {
        let viewController = ProductDetailViewController(
            slug: slug,
            repository: appContainer.productDetailRepository,
            imageLoader: appContainer.imageLoader
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
