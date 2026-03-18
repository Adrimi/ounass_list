import Foundation

protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

struct ResourceLoadingViewModel {
    let isLoading: Bool
}

struct ResourceErrorViewModel {
    let message: String?

    static var noError: ResourceErrorViewModel { ResourceErrorViewModel(message: nil) }
}
