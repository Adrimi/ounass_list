import Foundation

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    var presenter: LoadResourcePresenter<Resource, View>?
    private var isLoading = false
    private let loader: () async throws -> Resource

    init(loader: @escaping () async throws -> Resource) {
        self.loader = loader
    }

    func loadResource() {
        guard !isLoading else { return }
        isLoading = true
        presenter?.didStartLoading()

        Task { @MainActor in
            defer { self.isLoading = false }
            do {
                let resource = try await self.loader()
                self.presenter?.didFinishLoading(with: resource)
            } catch {
                self.presenter?.didFinishLoading(with: error)
            }
        }
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}
