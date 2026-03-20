import Testing
@testable import OunassCaseStudy

struct APIIntegrationTests {
    private let listRepository = ProductListRepository()
    private let detailRepository = ProductDetailRepository()
    private let firstPage: ProductListPage

    init() async throws {
        firstPage = try await listRepository.fetchFirstPage()
    }

    // MARK: - Product List

    @Test func testListEndpointReturnsProducts() {
        #expect(!firstPage.products.isEmpty, "Expected at least one product")
    }

    @Test func testListProductFieldsArePopulated() throws {
        let product = try #require(firstPage.products.first, "Expected at least one product")
        #expect(!product.id.isEmpty, "id must not be empty")
        #expect(!product.slug.isEmpty, "slug must not be empty")
        #expect(!product.name.isEmpty, "name must not be empty")
        #expect(!product.designerName.isEmpty, "designerName must not be empty")
        #expect(product.price.amount > 0, "price must be > 0")
        #expect(product.thumbnailURL != nil, "thumbnailURL must be resolvable")
    }

    @Test func testListPaginationFieldsArePresent() {
        #expect(firstPage.nextPagePath != nil, "First page should have a next page")
    }

    // MARK: - Pagination

    @Test func testSecondPageReturnsDifferentProducts() async throws {
        let nextPath = try #require(firstPage.nextPagePath, "First page must have a next page path")

        let secondPage = try await listRepository.fetchPage(path: nextPath)
        #expect(!secondPage.products.isEmpty, "Second page must have products")
        let firstIDs = Set(firstPage.products.map(\.id))
        let secondIDs = Set(secondPage.products.map(\.id))
        #expect(firstIDs.isDisjoint(with: secondIDs), "Pages must not share product IDs")
    }

    // MARK: - Product Detail

    @Test func testDetailEndpointLoadsForFirstListProduct() async throws {
        let product = try #require(firstPage.products.first)

        let detail = try await detailRepository.fetchDetail(slug: product.slug)
        #expect(!detail.name.isEmpty, "name must not be empty")
        #expect(!detail.designerName.isEmpty, "designerName must not be empty")
        #expect(!detail.slug.isEmpty, "slug must not be empty")
        #expect(!detail.styleColorID.isEmpty, "styleColorID must not be empty")
        #expect(!detail.variants.isEmpty, "variants must not be empty")
    }

    @Test func testDetailSlugMatchesListSlug() async throws {
        let product = try #require(firstPage.products.first)

        let detail = try await detailRepository.fetchDetail(slug: product.slug)
        #expect(detail.slug == product.slug, "Detail slug must match the slug used in the request")
    }

    @Test func testDetailMediaURLsAreResolvable() async throws {
        let product = try #require(firstPage.products.first)

        let detail = try await detailRepository.fetchDetail(slug: product.slug)
        #expect(!detail.media.isEmpty, "Detail must have at least one media asset")
        for asset in detail.media {
            #expect(
                asset.url.absoluteString.hasPrefix("https://"),
                "Media URL must be https: \(asset.url)"
            )
        }
    }

    @Test func testDetailVariantsHaveValidSKUs() async throws {
        let product = try #require(firstPage.products.first)

        let detail = try await detailRepository.fetchDetail(slug: product.slug)
        #expect(!detail.variants.isEmpty, "Must have at least one variant")
        for variant in detail.variants {
            #expect(!variant.sku.isEmpty, "All variants must have a non-empty SKU")
            #expect(variant.price.amount > 0, "All variants must have a price > 0")
        }
    }

    // MARK: - Color Switch

    @Test func testColorSwitchDetailFetchesAlternateVariant() async throws {
        let products = firstPage.products

        guard let (originalSlug, alternateSlug) = try await findDetailWithMultipleColors(in: products) else {
            return
        }

        let detail = try await detailRepository.fetchDetail(slug: alternateSlug)
        #expect(!detail.name.isEmpty)
        #expect(detail.slug != originalSlug, "Alternate color detail should have a different slug")
    }

    private func findDetailWithMultipleColors(
        in products: [ProductSummary]
    ) async throws -> (originalSlug: String, alternateSlug: String)? {
        for product in products {
            let detail = try await detailRepository.fetchDetail(slug: product.slug)
            guard
                let colorGroup = detail.remoteSelectionSlugsByGroupID[ProductOptionGroupID.color],
                colorGroup.count > 1,
                let alternateSlug = colorGroup.first(where: { $0.key != detail.styleColorID })?.value
            else {
                continue
            }
            return (originalSlug: product.slug, alternateSlug: alternateSlug)
        }
        return nil
    }
}
