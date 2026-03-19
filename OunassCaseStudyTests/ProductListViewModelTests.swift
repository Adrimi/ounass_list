import Testing
import UIKit
@testable import OunassCaseStudy

@MainActor
struct ProductListUIIntegrationTests {
    @Test func test_viewDidLoadAndRefreshActions_requestFirstPageFromLoader() async {
        let (sut, loader) = makeSUT()

        #expect(loader.firstPageCallCount == 0)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            loader.firstPageCallCount == 1
        }
        #expect(loader.firstPageCallCount == 1)

        sut.simulateUserInitiatedReload()
        #expect(loader.firstPageCallCount == 1)

        loader.completeFirstPage(with: .firstPage)
        await waitFor {
            sut.renderedProductCount == 2
        }

        sut.simulateUserInitiatedReload()
        await waitFor {
            loader.firstPageCallCount == 2
        }
        #expect(loader.firstPageCallCount == 2)

        loader.completeFirstPage(with: .refreshPage, at: 1)
        await waitFor {
            sut.renderedProductCount == 1
        }
    }

    @Test func test_loadMoreActions_requestNextPageFromLoaderUntilLastPage() async {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: .firstPage)
        await waitFor {
            sut.canLoadMore
        }

        sut.simulateLoadMoreAction()
        await waitFor {
            loader.requestedPagePaths == ["/next"]
        }
        #expect(loader.requestedPagePaths == ["/next"])

        sut.simulateLoadMoreAction()
        #expect(loader.requestedPagePaths == ["/next"])

        loader.completeLoadMore(with: .secondPageWithMore)
        await waitFor {
            sut.renderedProductCount == 4 && sut.canLoadMore
        }

        sut.simulateLoadMoreAction()
        await waitFor {
            loader.requestedPagePaths == ["/next", "/next-2"]
        }
        #expect(loader.requestedPagePaths == ["/next", "/next-2"])

        loader.completeLoadMoreWithError(at: 1)
        await waitFor {
            sut.loadMoreErrorMessage == anyNSError().localizedDescription
        }

        sut.simulateTapOnLoadMoreError()
        await waitFor {
            loader.requestedPagePaths == ["/next", "/next-2", "/next-2"]
        }
        #expect(loader.requestedPagePaths == ["/next", "/next-2", "/next-2"])

        loader.completeLoadMore(with: .terminalPage, at: 2)
        await waitFor {
            !sut.canLoadMore
        }

        sut.simulateLoadMoreAction()
        #expect(loader.requestedPagePaths == ["/next", "/next-2", "/next-2"])
    }

    @Test func test_refreshCompletion_resetsRenderedProductsToFirstPageItems() async {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: .firstPage)
        await waitFor {
            sut.renderedProductCount == 2
        }

        sut.simulateLoadMoreAction()
        loader.completeLoadMore(with: .secondPage)
        await waitFor {
            sut.renderedProductCount == 4
        }

        sut.simulateUserInitiatedReload()
        loader.completeFirstPage(with: .refreshPage, at: 1)
        await waitFor {
            sut.renderedProductCount == 1 && !sut.canLoadMore
        }
    }

    @Test func test_loadMoreIndicator_isVisibleWhileLoadingMoreAndHiddenAfterCompletion() async {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: .firstPage)
        await waitFor {
            sut.canLoadMore
        }

        #expect(sut.isShowingLoadMoreIndicator == false)

        sut.simulateLoadMoreAction()
        #expect(sut.isShowingLoadMoreIndicator)

        loader.completeLoadMore(with: .secondPage)
        await waitFor {
            !sut.isShowingLoadMoreIndicator
        }
    }

    @Test func test_loadMoreCompletion_rendersErrorMessageAndClearsItOnRetry() async {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: .firstPage)
        await waitFor {
            sut.canLoadMore
        }

        sut.simulateLoadMoreAction()
        await waitFor {
            loader.requestedPagePaths == ["/next"]
        }
        loader.completeLoadMoreWithError()
        await waitFor {
            sut.loadMoreErrorMessage == anyNSError().localizedDescription
        }

        sut.simulateTapOnLoadMoreError()
        await waitFor {
            loader.requestedPagePaths == ["/next", "/next"]
        }
        #expect(loader.requestedPagePaths == ["/next", "/next"])
        #expect(sut.loadMoreErrorMessage == nil)
        #expect(sut.isShowingLoadMoreIndicator)

        loader.completeLoadMore(with: .terminalPage, at: 1)
        await waitFor {
            !sut.canLoadMore
        }
    }

    @Test func test_productSelection_notifiesHandlerForInitialAndAppendedProducts() async {
        var selectedProducts: [ProductSummary] = []
        let (sut, loader) = makeSUT(
            selection: { selectedProducts.append($0) },
            imageLoader: FakeImageLoader()
        )

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: .firstPage)
        await waitFor {
            sut.renderedProductCount == 2
        }

        sut.simulateTapOnProduct(at: 0)

        sut.simulateLoadMoreAction()
        loader.completeLoadMore(with: .secondPage)
        await waitFor {
            sut.renderedProductCount == 4
        }

        sut.simulateTapOnProduct(at: 2)

        #expect(selectedProducts.map(\.id) == ["0", "2"])
    }

    private func makeSUT(
        selection: @escaping (ProductSummary) -> Void = { _ in },
        imageLoader: ImageLoader = FakeImageLoader()
    ) -> (ProductListViewController, ProductListLoaderSpy) {
        let loader = ProductListLoaderSpy()
        let sut = ProductListUIComposer.make(
            repository: loader,
            imageLoader: imageLoader,
            onSelection: selection
        )

        return (sut, loader)
    }

    private func waitFor(_ condition: () -> Bool) async {
        for _ in 0..<40 {
            if condition() {
                return
            }
            await Task.yield()
        }

        Issue.record("Timed out waiting for product list UI update")
    }
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

    static let secondPageWithMore = ProductListPage(
        products: [
            .sample(id: "2"),
            .sample(id: "3")
        ],
        pagination: PaginationInfo(nextPagePath: "/next-2", totalItems: 6, currentSet: 2, viewSize: 2),
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

@MainActor
private final class ProductListLoaderSpy: ProductListRepositoryProtocol {
    private var firstPageContinuations = [CheckedContinuation<ProductListPage, Error>?]()
    private var loadMoreContinuations = [CheckedContinuation<ProductListPage, Error>?]()
    private var pendingFirstPageResults = [Int: Result<ProductListPage, Error>]()
    private var pendingLoadMoreResults = [Int: Result<ProductListPage, Error>]()

    private(set) var firstPageCallCount = 0
    private(set) var requestedPagePaths: [String] = []

    func fetchFirstPage() async throws -> ProductListPage {
        let index = firstPageCallCount
        firstPageCallCount += 1

        if let result = pendingFirstPageResults.removeValue(forKey: index) {
            return try result.get()
        }

        return try await withCheckedThrowingContinuation { continuation in
            firstPageContinuations.append(continuation)
        }
    }

    func fetchPage(path: String) async throws -> ProductListPage {
        let index = requestedPagePaths.count
        requestedPagePaths.append(path)

        if let result = pendingLoadMoreResults.removeValue(forKey: index) {
            return try result.get()
        }

        return try await withCheckedThrowingContinuation { continuation in
            loadMoreContinuations.append(continuation)
        }
    }

    func completeFirstPage(with page: ProductListPage, at index: Int = 0) {
        resolve(
            .success(page),
            at: index,
            continuations: &firstPageContinuations,
            pendingResults: &pendingFirstPageResults
        )
    }

    func completeLoadMore(with page: ProductListPage, at index: Int = 0) {
        resolve(
            .success(page),
            at: index,
            continuations: &loadMoreContinuations,
            pendingResults: &pendingLoadMoreResults
        )
    }

    func completeLoadMoreWithError(_ error: Error = anyNSError(), at index: Int = 0) {
        resolve(
            .failure(error),
            at: index,
            continuations: &loadMoreContinuations,
            pendingResults: &pendingLoadMoreResults
        )
    }

    private func resolve(
        _ result: Result<ProductListPage, Error>,
        at index: Int,
        continuations: inout [CheckedContinuation<ProductListPage, Error>?],
        pendingResults: inout [Int: Result<ProductListPage, Error>]
    ) {
        guard continuations.indices.contains(index), let continuation = continuations[index] else {
            pendingResults[index] = result
            return
        }

        continuations[index] = nil
        continuation.resume(with: result)
    }
}

private extension ProductListViewController {
    func loadViewIfNeededForTesting() {
        loadViewIfNeeded()
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        view.layoutIfNeeded()
    }

    func simulateUserInitiatedReload() {
        collectionVC.onRefresh?()
    }

    func simulateLoadMoreAction() {
        let indexPath = IndexPath(item: 0, section: 1)
        makeCellVisible(at: indexPath)
        let loadMoreCell = loadMoreCell() ?? UICollectionViewCell()
        collectionVC.collectionView.delegate?.collectionView?(
            collectionVC.collectionView,
            willDisplay: loadMoreCell,
            forItemAt: indexPath
        )
    }

    func simulateTapOnLoadMoreError() {
        guard canLoadMore else { return }
        let indexPath = IndexPath(item: 0, section: 1)
        collectionVC.collectionView.delegate?.collectionView?(
            collectionVC.collectionView,
            didSelectItemAt: indexPath
        )
    }

    func simulateTapOnProduct(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionVC.collectionView.delegate?.collectionView?(
            collectionVC.collectionView,
            didSelectItemAt: indexPath
        )
    }

    var renderedProductCount: Int {
        numberOfItems(in: 0)
    }

    var canLoadMore: Bool {
        numberOfItems(in: 1) > 0
    }

    var isShowingLoadMoreIndicator: Bool {
        loadMoreCell()?.isLoading == true
    }

    var loadMoreErrorMessage: String? {
        loadMoreCell()?.message
    }

    private func loadMoreCell() -> LoadMoreCell? {
        guard canLoadMore else { return nil }
        return cell(at: IndexPath(item: 0, section: 1)) as? LoadMoreCell
    }

    private func numberOfItems(in section: Int) -> Int {
        guard collectionVC.collectionView.numberOfSections > section else { return 0 }
        return collectionVC.collectionView.numberOfItems(inSection: section)
    }

    private func cell(at indexPath: IndexPath) -> UICollectionViewCell? {
        guard numberOfItems(in: indexPath.section) > indexPath.item else { return nil }
        view.layoutIfNeeded()
        collectionVC.view.layoutIfNeeded()
        collectionVC.collectionView.layoutIfNeeded()
        return collectionVC.collectionView.cellForItem(at: indexPath)
    }

    private func makeCellVisible(at indexPath: IndexPath) {
        guard numberOfItems(in: indexPath.section) > indexPath.item else { return }
        collectionVC.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        view.layoutIfNeeded()
        collectionVC.view.layoutIfNeeded()
        collectionVC.collectionView.layoutIfNeeded()
    }
}

private func anyNSError() -> NSError {
    NSError(domain: "ProductListUIIntegrationTests", code: 0)
}
