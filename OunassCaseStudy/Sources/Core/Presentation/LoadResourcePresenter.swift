import Foundation

final class LoadResourcePresenter<Resource, View: ResourceView> {
    private let resourceView: View
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    private let mapper: (Resource) throws -> View.ResourceViewModel

    init(
        resourceView: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView,
        mapper: @escaping (Resource) throws -> View.ResourceViewModel
    ) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }

    func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }

    func didFinishLoading(with error: Error) {
        errorView.display(ResourceErrorViewModel(message: error.localizedDescription))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}

extension LoadResourcePresenter where Resource == View.ResourceViewModel {
    convenience init(
        resourceView: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) {
        self.init(resourceView: resourceView, loadingView: loadingView, errorView: errorView, mapper: { $0 })
    }
}
