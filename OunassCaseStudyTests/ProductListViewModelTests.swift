import Testing
@testable import OunassCaseStudy

@MainActor
struct ProductListViewModelTests {
    @Test func testInitialLoadPublishesProducts() async {
        let service = MockProductListRepository()
        service.firstPageResult = .success(.firstPage)
        let viewModel = ProductListViewModel(repository: service)
        var lastState: ProductListViewState?

        viewModel.onStateChange = { lastState = $0 }
        viewModel.loadInitialIfNeeded()
        await Task.yield()

        #expect(lastState?.products.count == 2)
        #expect(service.fetchFirstPageCount == 1)
    }

    @Test func testLoadNextPageAppendsAndPreventsDuplicateRequest() async {
        let service = MockProductListRepository()
        service.firstPageResult = .success(.firstPage)
        service.nextPageResult = .success(.secondPage)
        let viewModel = ProductListViewModel(repository: service)

        viewModel.loadInitialIfNeeded()
        await Task.yield()
        viewModel.loadNextPageIfNeeded(currentItemID: ProductSummary.sample(id: "1").id)
        viewModel.loadNextPageIfNeeded(currentItemID: ProductSummary.sample(id: "1").id)
        await Task.yield()

        #expect(service.fetchPageRequests == ["/next"])
    }

    @Test func testRefreshResetsProductsAndPagination() async {
        let service = MockProductListRepository()
        service.firstPageResult = .success(.firstPage)
        service.nextPageResult = .success(.secondPage)
        service.refreshResult = .success(.refreshPage)
        let viewModel = ProductListViewModel(repository: service)
        var lastState: ProductListViewState?

        viewModel.onStateChange = { lastState = $0 }
        viewModel.loadInitialIfNeeded()
        await Task.yield()
        viewModel.loadNextPageIfNeeded(currentItemID: ProductSummary.sample(id: "1").id)
        await Task.yield()
        viewModel.refresh()
        await Task.yield()

        #expect(lastState?.products.map(\.id) == ["r1"])
    }

    @Test func testTerminalPageDoesNotTriggerAnotherRequest() async {
        let service = MockProductListRepository()
        service.firstPageResult = .success(.terminalPage)
        let viewModel = ProductListViewModel(repository: service)

        viewModel.loadInitialIfNeeded()
        await Task.yield()
        viewModel.loadNextPageIfNeeded(currentItemID: ProductSummary.sample(id: "terminal").id)
        await Task.yield()

        #expect(service.fetchPageRequests.isEmpty)
    }
}

@MainActor
private class MockProductListRepository: ProductListRepositoryProtocol {
    var firstPageResult: Result<ProductListPage, Error> = .failure(MockError.notConfigured)
    var nextPageResult: Result<ProductListPage, Error> = .failure(MockError.notConfigured)
    var refreshResult: Result<ProductListPage, Error> = .failure(MockError.notConfigured)
    var fetchFirstPageCount = 0
    var fetchPageRequests: [String] = []

    func fetchFirstPage() async throws -> ProductListPage {
        fetchFirstPageCount += 1
        return try firstPageResult.get()
    }

    func fetchPage(path: String) async throws -> ProductListPage {
        fetchPageRequests.append(path)
        return try nextPageResult.get()
    }

    func refresh() async throws -> ProductListPage {
        try refreshResult.get()
    }
}

private enum MockError: Error {
    case notConfigured
}

private extension ProductListPage {
    static let firstPage = ProductListPage(
        products: [
            .sample(id: "0"),
            .sample(id: "1")
        ],
        pagination: PaginationInfo(nextPagePath: "/next", totalItems: 4, currentSet: 1, viewSize: 2),
        noFilterPath: nil
    )

    static let secondPage = ProductListPage(
        products: [
            .sample(id: "2"),
            .sample(id: "3")
        ],
        pagination: PaginationInfo(nextPagePath: nil, totalItems: 4, currentSet: 2, viewSize: 2),
        noFilterPath: nil
    )

    static let refreshPage = ProductListPage(
        products: [
            .sample(id: "r1")
        ],
        pagination: PaginationInfo(nextPagePath: nil, totalItems: 1, currentSet: 1, viewSize: 1),
        noFilterPath: nil
    )

    static let terminalPage = ProductListPage(
        products: [
            .sample(id: "terminal")
        ],
        pagination: PaginationInfo(nextPagePath: nil, totalItems: 1, currentSet: 1, viewSize: 1),
        noFilterPath: nil
    )
}

private extension ProductSummary {
    static func sample(id: String) -> ProductSummary {
        ProductSummary(
            id: id,
            slug: "slug-\(id)",
            name: "Item \(id)",
            designerName: "Designer",
            price: Money(amount: 100, currencyCode: "AED"),
            thumbnailURL: nil,
            hoverImageURL: nil
        )
    }
}
