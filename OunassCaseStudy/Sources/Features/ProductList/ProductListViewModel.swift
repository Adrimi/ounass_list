import Foundation

struct ProductListViewState: Equatable {
    let products: [ProductSummary]
    let isInitialLoading: Bool
    let isRefreshing: Bool
    let isLoadingNextPage: Bool
    let errorMessage: String?
}

@MainActor
final class ProductListViewModel {
    var onStateChange: ((ProductListViewState) -> Void)?
    var onProductSelection: ((ProductSummary) -> Void)?

    private let repository: ProductListRepositoryProtocol
    private var products: [ProductSummary] = []
    private var pagination: PaginationInfo?
    private var requestedPagePaths = Set<String>()
    private var isInitialLoading = false
    private var isRefreshing = false
    private var isLoadingNextPage = false
    private var errorMessage: String?

    init(repository: ProductListRepositoryProtocol) {
        self.repository = repository
    }

    func loadInitialIfNeeded() {
        guard products.isEmpty, isInitialLoading == false else {
            publishState()
            return
        }

        isInitialLoading = true
        errorMessage = nil
        publishState()

        Task {
            do {
                let page = try await repository.fetchFirstPage()
                products = page.products
                pagination = page.pagination
                errorMessage = nil
                requestedPagePaths.removeAll()
            } catch {
                errorMessage = error.localizedDescription
            }
            isInitialLoading = false
            publishState()
        }
    }

    func refresh() {
        guard isRefreshing == false else {
            return
        }

        isRefreshing = true
        errorMessage = nil
        publishState()

        Task {
            do {
                let page = try await repository.refresh()
                products = page.products
                pagination = page.pagination
                errorMessage = nil
                requestedPagePaths.removeAll()
            } catch {
                errorMessage = error.localizedDescription
            }
            isRefreshing = false
            publishState()
        }
    }

    func loadNextPageIfNeeded(currentItemID: String) {
        guard
            isInitialLoading == false,
            isRefreshing == false,
            isLoadingNextPage == false,
            let pagination,
            let nextPagePath = pagination.nextPagePath,
            requestedPagePaths.contains(nextPagePath) == false
        else {
            return
        }

        guard let currentIndex = products.firstIndex(where: { $0.id == currentItemID }) else {
            return
        }

        let thresholdIndex = max(products.count - 6, 0)
        guard currentIndex >= thresholdIndex else {
            return
        }

        isLoadingNextPage = true
        requestedPagePaths.insert(nextPagePath)
        publishState()

        Task {
            do {
                let page = try await repository.fetchPage(path: nextPagePath)
                let existingIDs = Set(products.map(\.id))
                let newProducts = page.products.filter { existingIDs.contains($0.id) == false }
                products.append(contentsOf: newProducts)
                self.pagination = page.pagination
                errorMessage = nil
            } catch {
                requestedPagePaths.remove(nextPagePath)
                errorMessage = error.localizedDescription
            }
            isLoadingNextPage = false
            publishState()
        }
    }

    func selectProduct(at index: Int) {
        guard products.indices.contains(index) else {
            return
        }

        onProductSelection?(products[index])
    }

    private func publishState() {
        onStateChange?(
            ProductListViewState(
                products: products,
                isInitialLoading: isInitialLoading,
                isRefreshing: isRefreshing,
                isLoadingNextPage: isLoadingNextPage,
                errorMessage: errorMessage
            )
        )
    }
}
