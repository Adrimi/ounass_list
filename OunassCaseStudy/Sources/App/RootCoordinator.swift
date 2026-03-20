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
        styleNavigationBar()
        navigationController.view.backgroundColor = .appBackground
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showProductList()
    }

    private func styleNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.titleTextAttributes = [
            .font: UIFont.sans(size: 17, weight: .medium),
            .foregroundColor: UIColor.primary
        ]
        let bar = navigationController.navigationBar
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.prefersLargeTitles = false
        bar.tintColor = .primary
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
        let viewController = ProductDetailUIComposer.make(
            slug: slug,
            repository: appContainer.productDetailRepository,
            imageLoader: appContainer.imageLoader
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
