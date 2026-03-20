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
        await waitFor {
            !sut.isShowingLoadMoreIndicator
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
        await waitFor {
            !sut.isShowingLoadMoreIndicator
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

    @Test func test_productImageLoad_requestsImageOnDisplayShowsRetryAndRendersImageOnRetrySuccess() async {
        let imageLoader = ImageLoaderSpy()
        let (sut, loader) = makeSUT(imageLoader: imageLoader)
        let url = imageURL(id: "display")
        let page = ProductListPage.make(products: [.sample(id: "0", thumbnailURL: url)])

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: page)
        await waitFor {
            sut.renderedProductCount == 1
        }

        sut.makeProductVisible(at: 0)
        await waitFor {
            imageLoader.requestCount == 1
        }

        #expect(imageLoader.requestedURLs == [url])
        #expect(sut.isShowingProductImageLoadingIndicator(at: 0))

        imageLoader.completeWithError()
        await waitFor {
            sut.isShowingProductImageRetryAction(at: 0)
        }

        #expect(sut.isShowingProductImageRetryAction(at: 0))
        #expect(!sut.isShowingProductImageLoadingIndicator(at: 0))

        sut.simulateTapOnProductImageRetry(at: 0)
        await waitFor {
            imageLoader.requestCount == 2
        }

        #expect(!sut.isShowingProductImageRetryAction(at: 0))
        #expect(sut.isShowingProductImageLoadingIndicator(at: 0))

        let image = UIImage.make(withColor: .systemBlue)
        imageLoader.complete(with: image, at: 1)
        await waitFor {
            sut.renderedProductImage(at: 0) != nil
        }

        #expect(sut.renderedProductImage(at: 0)?.pngData() == image.pngData())
        #expect(!sut.isShowingProductImageRetryAction(at: 0))
        #expect(!sut.isShowingProductImageLoadingIndicator(at: 0))
    }

    @Test func test_productImagePrefetch_requestsImageForOffscreenProduct() async {
        let imageLoader = ImageLoaderSpy()
        let (sut, loader) = makeSUT(imageLoader: imageLoader)
        let offscreenURL = imageURL(id: "prefetch")
        let products = (0..<12).map { index in
            ProductSummary.sample(
                id: "\(index)",
                thumbnailURL: index == 10 ? offscreenURL : nil
            )
        }

        sut.loadViewIfNeededForTesting()
        loader.completeFirstPage(with: .make(products: products))
        await waitFor {
            sut.renderedProductCount == products.count
        }

        sut.simulatePrefetchProduct(at: 10)
        await waitFor {
            imageLoader.requestCount == 1
        }

        #expect(imageLoader.requestedURLs == [offscreenURL])
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
        for _ in 0..<150 {
            if condition() {
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        Issue.record("Timed out waiting for product list UI update")
    }
}

@MainActor
struct LoadResourcePresentationAdapterTests {
    @Test func test_didRequestImage_requestsLoaderOnlyOnceWhileLoadIsInFlight() async {
        let loader = ImageLoaderSpy()
        let resourceView = ImageResourceViewSpy()
        let loadingView = LoadingViewSpy()
        let errorView = ErrorViewSpy()
        let sut = makeSUT(loader: loader, resourceView: resourceView, loadingView: loadingView, errorView: errorView)

        sut.didRequestImage()
        sut.didRequestImage()

        await waitFor {
            loader.requestCount == 1
        }

        #expect(loader.requestCount == 1)
        #expect(loadingView.models == [true])
        #expect(errorView.messages == [nil])
    }

    @Test func test_didCancelImageRequest_doesNotDeliverCancelledImage() async {
        let loader = ImageLoaderSpy()
        let resourceView = ImageResourceViewSpy()
        let loadingView = LoadingViewSpy()
        let errorView = ErrorViewSpy()
        let sut = makeSUT(loader: loader, resourceView: resourceView, loadingView: loadingView, errorView: errorView)

        sut.didRequestImage()
        await waitFor {
            loader.requestCount == 1
        }

        sut.didCancelImageRequest()
        loader.complete(with: .make(withColor: .systemRed))
        await flushTasks()

        #expect(resourceView.images.isEmpty)
        #expect(loadingView.models == [true])
        #expect(errorView.messages == [nil])
    }

    @Test func test_didCancelImageRequest_ignoresStaleCompletionAfterNewRequest() async {
        let loader = ImageLoaderSpy()
        let resourceView = ImageResourceViewSpy()
        let loadingView = LoadingViewSpy()
        let errorView = ErrorViewSpy()
        let sut = makeSUT(loader: loader, resourceView: resourceView, loadingView: loadingView, errorView: errorView)
        let expectedImage = UIImage.make(withColor: .systemGreen)

        sut.didRequestImage()
        await waitFor {
            loader.requestCount == 1
        }

        sut.didCancelImageRequest()
        sut.didRequestImage()
        await waitFor {
            loader.requestCount == 2
        }

        loader.complete(with: .make(withColor: .systemRed), at: 0)
        await flushTasks()
        #expect(resourceView.images.isEmpty)

        loader.complete(with: expectedImage, at: 1)
        await waitFor {
            resourceView.images.count == 1
        }

        #expect(resourceView.images.first?.pngData() == expectedImage.pngData())
        #expect(loadingView.models == [true, true, false])
        #expect(errorView.messages == [nil, nil])
    }

    @Test func test_didRequestImage_retriesAfterFailureWithNewRequest() async {
        let loader = ImageLoaderSpy()
        let resourceView = ImageResourceViewSpy()
        let loadingView = LoadingViewSpy()
        let errorView = ErrorViewSpy()
        let sut = makeSUT(loader: loader, resourceView: resourceView, loadingView: loadingView, errorView: errorView)
        let error = anyNSError()

        sut.didRequestImage()
        await waitFor {
            loader.requestCount == 1
        }

        loader.completeWithError(error)
        await waitFor {
            errorView.messages.last == error.localizedDescription
        }

        sut.didRequestImage()
        await waitFor {
            loader.requestCount == 2
        }

        #expect(loadingView.models == [true, false, true])
        #expect(errorView.messages == [nil, error.localizedDescription, nil])
    }

    private func makeSUT(
        loader: ImageLoaderSpy,
        resourceView: ImageResourceViewSpy,
        loadingView: LoadingViewSpy,
        errorView: ErrorViewSpy
    ) -> LoadResourcePresentationAdapter<UIImage, ImageResourceViewSpy> {
        let url = imageURL(id: "adapter")
        let sut = LoadResourcePresentationAdapter<UIImage, ImageResourceViewSpy>(
            loader: { try await loader.loadImage(from: url) }
        )

        sut.presenter = LoadResourcePresenter(
            resourceView: resourceView,
            loadingView: loadingView,
            errorView: errorView
        )

        return sut
    }

    private func waitFor(_ condition: () -> Bool) async {
        for _ in 0..<120 {
            if condition() {
                return
            }
            await Task.yield()
        }

        Issue.record("Timed out waiting for adapter state update")
    }

    private func flushTasks() async {
        await Task.yield()
        await Task.yield()
        await Task.yield()
    }
}

private extension ProductListPage {
    static let firstPage = ProductListPage(
        products: [
            .sample(id: "0"),
            .sample(id: "1")
        ],
        nextPagePath: "/next"
    )

    static let secondPage = ProductListPage(
        products: [
            .sample(id: "2"),
            .sample(id: "3")
        ],
        nextPagePath: nil
    )

    static let secondPageWithMore = ProductListPage(
        products: [
            .sample(id: "2"),
            .sample(id: "3")
        ],
        nextPagePath: "/next-2"
    )

    static let refreshPage = ProductListPage(
        products: [
            .sample(id: "r1")
        ],
        nextPagePath: nil
    )

    static let terminalPage = ProductListPage(
        products: [
            .sample(id: "terminal")
        ],
        nextPagePath: nil
    )

    static func make(products: [ProductSummary]) -> ProductListPage {
        ProductListPage(
            products: products,
            nextPagePath: nil
        )
    }
}

private extension ProductSummary {
    static func sample(id: String, thumbnailURL: URL? = nil) -> ProductSummary {
        ProductSummary(
            id: id,
            slug: "slug-\(id)",
            name: "Item \(id)",
            designerName: "Designer",
            price: Money(amount: 100, currencyCode: "AED"),
            thumbnailURL: thumbnailURL
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
        ensureContinuationSlot(in: &firstPageContinuations, at: index)

        if let result = pendingFirstPageResults.removeValue(forKey: index) {
            return try result.get()
        }

        return try await withCheckedThrowingContinuation { continuation in
            firstPageContinuations[index] = continuation
        }
    }

    func fetchPage(path: String) async throws -> ProductListPage {
        let index = requestedPagePaths.count
        requestedPagePaths.append(path)
        ensureContinuationSlot(in: &loadMoreContinuations, at: index)

        if let result = pendingLoadMoreResults.removeValue(forKey: index) {
            return try result.get()
        }

        return try await withCheckedThrowingContinuation { continuation in
            loadMoreContinuations[index] = continuation
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

    private func ensureContinuationSlot(
        in continuations: inout [CheckedContinuation<ProductListPage, Error>?],
        at index: Int
    ) {
        guard continuations.count <= index else { return }
        continuations.append(contentsOf: Array(repeating: nil, count: index - continuations.count + 1))
    }
}

private final class ImageLoaderSpy: ImageLoader {
    private let lock = NSLock()
    private var continuations = [CheckedContinuation<UIImage, Error>?]()
    private var pendingResults = [Int: Result<UIImage, Error>]()
    private var storedRequestedURLs: [URL] = []

    var requestCount: Int {
        synchronized { storedRequestedURLs.count }
    }

    var requestedURLs: [URL] {
        synchronized { storedRequestedURLs }
    }

    func loadImage(from url: URL) async throws -> UIImage {
        let index = synchronized {
            let index = storedRequestedURLs.count
            storedRequestedURLs.append(url)
            return index
        }

        if let result = synchronized({ pendingResults.removeValue(forKey: index) }) {
            return try result.get()
        }

        return try await withCheckedThrowingContinuation { continuation in
            synchronized {
                continuations.append(continuation)
            }
        }
    }

    func complete(with image: UIImage, at index: Int = 0) {
        resolve(.success(image), at: index)
    }

    func completeWithError(_ error: Error = anyNSError(), at index: Int = 0) {
        resolve(.failure(error), at: index)
    }

    private func resolve(_ result: Result<UIImage, Error>, at index: Int) {
        let continuation = synchronized { () -> CheckedContinuation<UIImage, Error>? in
            guard continuations.indices.contains(index), let continuation = continuations[index] else {
                pendingResults[index] = result
                return nil
            }

            continuations[index] = nil
            return continuation
        }

        continuation?.resume(with: result)
    }

    private func synchronized<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }
}

private final class ImageResourceViewSpy: ResourceView {
    typealias ResourceViewModel = UIImage

    private(set) var images: [UIImage] = []

    func display(_ viewModel: UIImage) {
        images.append(viewModel)
    }
}

private final class LoadingViewSpy: ResourceLoadingView {
    private(set) var models: [Bool] = []

    func display(_ viewModel: ResourceLoadingViewModel) {
        models.append(viewModel.isLoading)
    }
}

private final class ErrorViewSpy: ResourceErrorView {
    private(set) var messages: [String?] = []

    func display(_ viewModel: ResourceErrorViewModel) {
        messages.append(viewModel.message)
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
        makeCellVisible(at: indexPath)
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

    func simulatePrefetchProduct(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionVC.collectionView.prefetchDataSource?.collectionView(
            collectionVC.collectionView,
            prefetchItemsAt: [indexPath]
        )
    }

    func simulateTapOnProductImageRetry(at index: Int) {
        productCell(at: index)?.retryButton.sendActions(for: .touchUpInside)
    }

    func makeProductVisible(at index: Int) {
        makeCellVisible(at: IndexPath(item: index, section: 0))
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

    func isShowingProductImageLoadingIndicator(at index: Int) -> Bool {
        productCell(at: index)?.imageContainer.isShimmering == true
    }

    func isShowingProductImageRetryAction(at index: Int) -> Bool {
        productCell(at: index)?.retryButton.isHidden == false
    }

    func renderedProductImage(at index: Int) -> UIImage? {
        productCell(at: index)?.imageView.image
    }

    private func loadMoreCell() -> LoadMoreCell? {
        guard canLoadMore else { return nil }
        return cell(at: IndexPath(item: 0, section: 1)) as? LoadMoreCell
    }

    private func productCell(at index: Int) -> ProductListCell? {
        cell(at: IndexPath(item: index, section: 0)) as? ProductListCell
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

private func imageURL(id: String) -> URL {
    URL(string: "https://example.com/\(id).jpg")!
}
