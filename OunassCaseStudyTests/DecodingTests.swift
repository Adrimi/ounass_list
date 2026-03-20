import Testing
import Foundation
import UIKit
@testable import OunassCaseStudy

struct DecodingTests {
    private let decoder = JSONDecoder()

    @Test func testListResponseDecodesImportantFields() throws {
        let response = try decoder.decode(ProductListResponse.self, from: TestFixtures.listJSON)
        let page = response.toDomain()

        #expect(page.products.count == 2)
        #expect(page.products.first?.designerName == "Racil")
        #expect(page.products.first?.name == "Lee Fringed Kaftan")
        #expect(page.products.first?.price.amount == 3700)
        #expect(page.nextPagePath == "/women/clothing?fh_start_index=48")
    }

    @Test func testDetailResponseDecodesVariantOptions() throws {
        let response = try decoder.decode(ProductDetailResponse.self, from: TestFixtures.detailJSON)
        let detail = response.toDomain()

        #expect(detail.name == "Lee Fringed Kaftan")
        #expect(detail.optionGroups.map { $0.id } == [ProductOptionGroupID.color, ProductOptionGroupID.size])
        #expect(detail.variants.count == 3)
        #expect(detail.initialSelectedValues[ProductOptionGroupID.color] == "219370859_27")
        #expect(detail.remoteSelectionSlugsByGroupID[ProductOptionGroupID.color]?["219370859_14"] == "shop-racil-lee-fringed-kaftan-for-women-219370859_14")
        #expect(detail.variants.first?.price.amount == 3700)
    }

    @Test func testDetailResponseHandlesMissingOptionalFields() throws {
        let response = try decoder.decode(ProductDetailResponse.self, from: TestFixtures.minimalDetailJSON)
        let detail = response.toDomain()

        #expect(detail.variants.count == 1)
        #expect(detail.optionGroups.isEmpty)
        #expect(detail.amberPoints == nil)
        #expect(detail.description == "")
    }

    @Test func testDetailPresenterFormatsDisplayedVariantAmberPoints() {
        let detail = makeDetail(amberPoints: 100)
        let displayedVariant = makeVariant(id: "variant", amberPoints: 3523)
        let state = SelectionState(
            selectedValueIDs: [:],
            groups: [],
            selectedVariant: displayedVariant,
            displayedVariant: displayedVariant,
            isAddToBagEnabled: true
        )

        let model = ProductDetailPresenter.map(detail, selectionState: state)

        #expect(model.amberPointsText == "3523 Amber points")
    }

    @Test func testDetailPresenterFallsBackToDetailAmberPointsWhenVariantHasNone() {
        let detail = makeDetail(amberPoints: 2048)
        let displayedVariant = makeVariant(id: "variant", amberPoints: nil)
        let state = SelectionState(
            selectedValueIDs: [:],
            groups: [],
            selectedVariant: displayedVariant,
            displayedVariant: displayedVariant,
            isAddToBagEnabled: true
        )

        let model = ProductDetailPresenter.map(detail, selectionState: state)

        #expect(model.amberPointsText == "2048 Amber points")
    }

    @Test func testDetailPresenterFormatsDisplayedVariantProductID() {
        let detail = makeDetail(amberPoints: nil)
        let displayedVariant = makeVariant(id: "variant-123", amberPoints: nil)
        let state = SelectionState(
            selectedValueIDs: [:],
            groups: [],
            selectedVariant: displayedVariant,
            displayedVariant: displayedVariant,
            isAddToBagEnabled: true
        )

        let model = ProductDetailPresenter.map(detail, selectionState: state)

        #expect(model.productIDText == "PRODUCT ID: variant-123")
    }

    private func makeDetail(amberPoints: Int?) -> ProductDetail {
        ProductDetail(
            styleColorID: "style-color",
            slug: "slug",
            name: "Lee Fringed Kaftan",
            designerName: "Racil",
            description: "Description",
            amberPoints: amberPoints,
            media: [MediaAsset(id: "media", url: URL(string: "https://example.com/media.jpg")!)],
            optionGroups: [],
            variants: [],
            initialSelectedValues: [:],
            fallbackVariantID: "variant",
            remoteSelectionSlugsByGroupID: [:]
        )
    }

    private func makeVariant(id: String, amberPoints: Int?) -> ProductVariant {
        ProductVariant(
            id: id,
            sku: id,
            optionValueIDs: [:],
            description: "Description",
            media: [MediaAsset(id: "media", url: URL(string: "https://example.com/media.jpg")!)],
            price: Money(amount: 3700, currencyCode: "AED"),
            amberPoints: amberPoints,
            isAvailable: true
        )
    }
}

@MainActor
struct ProductDetailUIIntegrationTests {
    @Test func test_selectingAlternateColorRequestsMappedRemoteSlugAndUpdatesDisplayedProductID() async throws {
        let yellowDetail = makeColorDetail(
            styleColorID: "yellow",
            slug: "shop-racil-lee-fringed-kaftan-for-women-219370859_27",
            sku: "sku-yellow"
        )
        let blueDetail = makeColorDetail(
            styleColorID: "blue",
            slug: "shop-racil-lee-fringed-kaftan-for-women-219370859_14",
            sku: "sku-blue"
        )
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: yellowDetail.slug, repository: repository)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            repository.requestedSlugs == [yellowDetail.slug]
        }

        repository.complete(with: yellowDetail)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-yellow"
        }

        let blueControl = try #require(sut.optionControl(inGroupWithTitle: "Color", at: 1))
        #expect(blueControl.isEnabled)

        blueControl.sendActions(for: .touchUpInside)
        await waitFor {
            repository.requestedSlugs == [yellowDetail.slug, blueDetail.slug]
        }

        repository.complete(with: blueDetail, at: 1)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-blue"
        }
    }

    @Test func test_failedRemoteColorSwitchRetriesTheRequestedAlternateSlug() async throws {
        let yellowDetail = makeColorDetail(
            styleColorID: "yellow",
            slug: "shop-racil-lee-fringed-kaftan-for-women-219370859_27",
            sku: "sku-yellow"
        )
        let blueDetail = makeColorDetail(
            styleColorID: "blue",
            slug: "shop-racil-lee-fringed-kaftan-for-women-219370859_14",
            sku: "sku-blue"
        )
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: yellowDetail.slug, repository: repository)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            repository.requestedSlugs == [yellowDetail.slug]
        }

        repository.complete(with: yellowDetail)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-yellow"
        }

        let blueControl = try #require(sut.optionControl(inGroupWithTitle: "Color", at: 1))
        blueControl.sendActions(for: .touchUpInside)
        await waitFor {
            repository.requestedSlugs == [yellowDetail.slug, blueDetail.slug]
        }

        repository.completeWithError(at: 1)
        await waitFor {
            sut.errorMessage != nil
        }

        sut.simulateTapOnErrorBanner()
        await waitFor {
            repository.requestedSlugs == [yellowDetail.slug, blueDetail.slug, blueDetail.slug]
        }
    }

    @Test func test_selectingSizeUpdatesDisplayedProductID() async throws {
        let detail = makeSizeOnlyDetail()
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: detail.slug, repository: repository)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            repository.requestedSlugs == [detail.slug]
        }

        repository.complete(with: detail)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-s"
        }

        let mediumControl = try #require(sut.optionControl(inGroupWithTitle: "Size", at: 1))
        #expect(mediumControl.isEnabled)

        mediumControl.sendActions(for: .touchUpInside)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-m"
        }
    }

    private func makeSUT(initialSlug: String, repository: ProductDetailRepositorySpy) -> ProductDetailViewController {
        ProductDetailViewController(
            slug: initialSlug,
            repository: repository,
            imageLoader: FakeImageLoader()
        )
    }

    private func makeColorDetail(styleColorID: String, slug: String, sku: String) -> ProductDetail {
        ProductDetail(
            styleColorID: styleColorID,
            slug: slug,
            name: "Lee Fringed Kaftan",
            designerName: "Racil",
            description: "Description for \(styleColorID)",
            amberPoints: 3523,
            media: [MediaAsset.sample(id: sku)],
            optionGroups: [
                ProductOptionGroup(
                    id: ProductOptionGroupID.color,
                    title: "Color",
                    displayStyle: .swatch,
                    isRequired: true,
                    values: [
                        ProductOptionValue(id: "yellow", title: "Yellow", swatchHex: "#FEE877", isAvailable: true),
                        ProductOptionValue(id: "blue", title: "Blue", swatchHex: "#5E96E1", isAvailable: true)
                    ]
                )
            ],
            variants: [
                ProductVariant(
                    id: sku,
                    sku: sku,
                    optionValueIDs: [ProductOptionGroupID.color: styleColorID],
                    description: "Description for \(styleColorID)",
                    media: [MediaAsset.sample(id: sku)],
                    price: Money(amount: 3700, currencyCode: "AED"),
                    amberPoints: 3523,
                    isAvailable: true
                )
            ],
            initialSelectedValues: [ProductOptionGroupID.color: styleColorID],
            fallbackVariantID: sku,
            remoteSelectionSlugsByGroupID: [
                ProductOptionGroupID.color: [
                    "yellow": "shop-racil-lee-fringed-kaftan-for-women-219370859_27",
                    "blue": "shop-racil-lee-fringed-kaftan-for-women-219370859_14"
                ]
            ]
        )
    }

    private func makeSizeOnlyDetail() -> ProductDetail {
        ProductDetail(
            styleColorID: "size-only",
            slug: "shop-size-only-product",
            name: "Lee Fringed Kaftan",
            designerName: "Racil",
            description: "Description",
            amberPoints: 3523,
            media: [MediaAsset.sample(id: "sku-s")],
            optionGroups: [
                ProductOptionGroup(
                    id: ProductOptionGroupID.size,
                    title: "Size",
                    displayStyle: .text,
                    isRequired: true,
                    values: [
                        ProductOptionValue(id: "s", title: "S", swatchHex: nil, isAvailable: true),
                        ProductOptionValue(id: "m", title: "M", swatchHex: nil, isAvailable: true)
                    ]
                )
            ],
            variants: [
                ProductVariant(
                    id: "sku-s",
                    sku: "sku-s",
                    optionValueIDs: [ProductOptionGroupID.size: "s"],
                    description: "Small",
                    media: [MediaAsset.sample(id: "sku-s")],
                    price: Money(amount: 3700, currencyCode: "AED"),
                    amberPoints: 3523,
                    isAvailable: true
                ),
                ProductVariant(
                    id: "sku-m",
                    sku: "sku-m",
                    optionValueIDs: [ProductOptionGroupID.size: "m"],
                    description: "Medium",
                    media: [MediaAsset.sample(id: "sku-m")],
                    price: Money(amount: 3700, currencyCode: "AED"),
                    amberPoints: 3523,
                    isAvailable: true
                )
            ],
            initialSelectedValues: [:],
            fallbackVariantID: "sku-s",
            remoteSelectionSlugsByGroupID: [:]
        )
    }

    private func waitFor(_ condition: () -> Bool) async {
        for _ in 0..<150 {
            if condition() {
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        Issue.record("Timed out waiting for product detail UI update")
    }
}

@MainActor
private final class ProductDetailRepositorySpy: ProductDetailRepositoryProtocol {
    private var continuations = [CheckedContinuation<ProductDetail, Error>?]()
    private var pendingResults = [Int: Result<ProductDetail, Error>]()

    private(set) var requestedSlugs: [String] = []

    func fetchDetail(slug: String) async throws -> ProductDetail {
        let index = requestedSlugs.count
        requestedSlugs.append(slug)
        ensureContinuationSlot(at: index)

        if let result = pendingResults.removeValue(forKey: index) {
            return try result.get()
        }

        return try await withCheckedThrowingContinuation { continuation in
            continuations[index] = continuation
        }
    }

    func complete(with detail: ProductDetail, at index: Int = 0) {
        resolve(.success(detail), at: index)
    }

    func completeWithError(_ error: Error = anyNSError(), at index: Int = 0) {
        resolve(.failure(error), at: index)
    }

    private func resolve(_ result: Result<ProductDetail, Error>, at index: Int) {
        guard continuations.indices.contains(index), let continuation = continuations[index] else {
            pendingResults[index] = result
            return
        }

        continuations[index] = nil
        continuation.resume(with: result)
    }

    private func ensureContinuationSlot(at index: Int) {
        guard continuations.count <= index else { return }
        continuations.append(contentsOf: Array(repeating: nil, count: index - continuations.count + 1))
    }
}

private extension ProductDetailViewController {
    func loadViewIfNeededForTesting() {
        loadViewIfNeeded()
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        view.layoutIfNeeded()
    }

    func optionControl(inGroupWithTitle title: String, at index: Int) -> UIControl? {
        guard
            let groupView = view.allDescendantViews()
                .compactMap({ $0 as? UILabel })
                .first(where: { ($0.attributedText?.string ?? $0.text) == title })?
                .superview
        else {
            return nil
        }

        let controls = groupView.allDescendantViews().compactMap { $0 as? UIControl }
        guard controls.indices.contains(index) else { return nil }
        return controls[index]
    }

    var productIDText: String? {
        view.allDescendantViews()
            .compactMap { $0 as? UILabel }
            .compactMap { $0.attributedText?.string ?? $0.text }
            .first(where: { $0.hasPrefix("PRODUCT ID:") })
    }

    var errorMessage: String? {
        view.findSubview(ofType: ErrorView.self)?.message
    }

    func simulateTapOnErrorBanner() {
        guard let errorView = view.findSubview(ofType: ErrorView.self) else { return }
        let button = errorView.allDescendantViews().compactMap { $0 as? UIButton }.first
        button?.sendActions(for: .touchUpInside)
    }
}

private extension UIView {
    func allDescendantViews() -> [UIView] {
        [self] + subviews.flatMap { $0.allDescendantViews() }
    }

    func findSubview<T: UIView>(ofType type: T.Type) -> T? {
        allDescendantViews().compactMap { $0 as? T }.first
    }
}

private extension MediaAsset {
    static func sample(id: String) -> MediaAsset {
        MediaAsset(id: id, url: URL(string: "https://example.com/\(id).jpg")!)
    }
}

private func anyNSError() -> NSError {
    NSError(domain: "test", code: 0)
}
