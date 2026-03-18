import Testing
import UIKit
@testable import OunassCaseStudy

@MainActor
struct ProductListViewAdapterTests {
    @Test func testDisplayAccumulatesProducts() {
        let (adapter, _) = makeAdapter()

        adapter.display(.firstPage)
        #expect(adapter.productCount == 2)

        adapter.display(.secondPage)
        #expect(adapter.productCount == 4)
    }

    @Test func testDisplayDeduplicatesProducts() {
        let (adapter, _) = makeAdapter()

        adapter.display(.firstPage)
        adapter.display(.firstPage)
        #expect(adapter.productCount == 2)
    }

    @Test func testResetClearsState() {
        let (adapter, _) = makeAdapter()

        adapter.display(.firstPage)
        adapter.reset()
        adapter.display(.refreshPage)

        #expect(adapter.productCount == 1)
        #expect(adapter.currentPagination?.nextPagePath == nil)
    }

    @Test func testPaginationInfoIsUpdated() {
        let (adapter, _) = makeAdapter()

        adapter.display(.firstPage)
        #expect(adapter.currentPagination?.nextPagePath == "/next")

        adapter.display(.terminalPage)
        #expect(adapter.currentPagination?.nextPagePath == nil)
    }

    private func makeAdapter() -> (ProductListViewAdapter, CollectionViewController) {
        let collectionVC = CollectionViewController(layout: UICollectionViewFlowLayout())
        collectionVC.loadViewIfNeeded()
        collectionVC.collectionView.register(ProductListCell.self, forCellWithReuseIdentifier: ProductListCell.reuseIdentifier)
        let adapter = ProductListViewAdapter(
            controller: collectionVC,
            imageLoader: MockImageLoader(),
            selection: { _ in }
        )
        return (adapter, collectionVC)
    }
}

private class MockImageLoader: ImageLoader {
    func loadImage(from url: URL) async throws -> UIImage {
        .make(withColor: .red)
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
