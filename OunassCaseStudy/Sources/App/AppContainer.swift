import Foundation

final class AppContainer {
    let apiClient = RemoteHTTPClient()
    let imageLoader = RemoteImageLoader()

    lazy var productListRepository: ProductListRepository = {
        ProductListRepository(apiClient: apiClient)
    }()

    lazy var productDetailRepository: ProductDetailRepository = {
        ProductDetailRepository(apiClient: apiClient)
    }()
}
