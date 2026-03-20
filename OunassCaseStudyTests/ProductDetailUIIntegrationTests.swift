import Testing
import Foundation
import UIKit
@testable import OunassCaseStudy

@MainActor
struct ProductDetailUIIntegrationTests {
    @Test func test_viewDidLoadRequestsInitialSlug() async {
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: "initial-slug", repository: repository)

        sut.loadViewIfNeededForTesting()

        await waitFor {
            repository.requestedSlugs == ["initial-slug"]
        }
    }

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

    @Test func test_selectingAlternateTextColorRequestsMappedRemoteSlug() async throws {
        let decoder = JSONDecoder()
        let initialDetail = try decoder.decode(ProductDetailResponse.self, from: TestFixtures.textColorDetailJSON).toDomain()
        let obsidianDetail = makeTextColorDetail(
            styleColorID: "218694515_11264",
            slug: "shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_11264",
            selectedSKU: "218695067"
        )
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: initialDetail.slug, repository: repository)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            repository.requestedSlugs == [initialDetail.slug]
        }

        repository.complete(with: initialDetail)
        await waitFor {
            sut.productIDText == "PRODUCT ID: 219166417"
        }

        let largeControl = try #require(sut.optionControl(inGroupWithTitle: "Size", at: 1))
        let raisinControl = try #require(sut.optionControl(inGroupWithTitle: "Color", at: 1))
        let obsidianControl = try #require(sut.optionControl(inGroupWithTitle: "Color", at: 2))
        #expect(largeControl.isEnabled)
        #expect(!raisinControl.isEnabled)
        #expect(obsidianControl.isEnabled)

        largeControl.sendActions(for: .touchUpInside)
        await waitFor {
            sut.productIDText == "PRODUCT ID: 219166438"
        }

        obsidianControl.sendActions(for: .touchUpInside)
        await waitFor {
            repository.requestedSlugs == [
                initialDetail.slug,
                obsidianDetail.slug
            ]
        }

        repository.complete(with: obsidianDetail, at: 1)
        await waitFor {
            sut.productIDText == "PRODUCT ID: 218695067"
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

    @Test func test_selectingCachedRemoteDetailReusesCachedSlug() async throws {
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

        repository.complete(with: blueDetail, at: 1)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-blue"
        }

        let yellowControl = try #require(sut.optionControl(inGroupWithTitle: "Color", at: 0))
        yellowControl.sendActions(for: .touchUpInside)
        await waitFor {
            repository.requestedSlugs == [yellowDetail.slug, blueDetail.slug]
                && sut.productIDText == "PRODUCT ID: sku-yellow"
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

    @Test func test_remoteReloadPreservesNonSizeSelectionWhenValueStillExists() async throws {
        let matteDetail = makeFinishDetail(
            finishID: "matte",
            slug: "shop-finish-matte",
            regularSKU: "sku-matte-regular",
            petiteSKU: "sku-matte-petite",
            petiteIsAvailable: true
        )
        let glossDetail = makeFinishDetail(
            finishID: "gloss",
            slug: "shop-finish-gloss",
            regularSKU: "sku-gloss-regular",
            petiteSKU: "sku-gloss-petite",
            petiteIsAvailable: true
        )
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: matteDetail.slug, repository: repository)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            repository.requestedSlugs == [matteDetail.slug]
        }

        repository.complete(with: matteDetail)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-matte-regular"
        }

        let petiteControl = try #require(sut.optionControl(inGroupWithTitle: "Fit", at: 1))
        petiteControl.sendActions(for: .touchUpInside)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-matte-petite"
        }

        let glossControl = try #require(sut.optionControl(inGroupWithTitle: "Finish", at: 1))
        glossControl.sendActions(for: .touchUpInside)
        await waitFor {
            repository.requestedSlugs == [matteDetail.slug, glossDetail.slug]
        }

        repository.complete(with: glossDetail, at: 1)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-gloss-petite"
        }
    }

    @Test func test_remoteReloadFallsBackWhenPreservedSelectionIsUnavailable() async throws {
        let matteDetail = makeFinishDetail(
            finishID: "matte",
            slug: "shop-finish-matte",
            regularSKU: "sku-matte-regular",
            petiteSKU: "sku-matte-petite",
            petiteIsAvailable: true
        )
        let glossDetail = makeFinishDetail(
            finishID: "gloss",
            slug: "shop-finish-gloss",
            regularSKU: "sku-gloss-regular",
            petiteSKU: "sku-gloss-petite",
            petiteIsAvailable: false
        )
        let repository = ProductDetailRepositorySpy()
        let sut = makeSUT(initialSlug: matteDetail.slug, repository: repository)

        sut.loadViewIfNeededForTesting()
        await waitFor {
            repository.requestedSlugs == [matteDetail.slug]
        }

        repository.complete(with: matteDetail)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-matte-regular"
        }

        let petiteControl = try #require(sut.optionControl(inGroupWithTitle: "Fit", at: 1))
        petiteControl.sendActions(for: .touchUpInside)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-matte-petite"
        }

        let glossControl = try #require(sut.optionControl(inGroupWithTitle: "Finish", at: 1))
        glossControl.sendActions(for: .touchUpInside)
        await waitFor {
            repository.requestedSlugs == [matteDetail.slug, glossDetail.slug]
        }

        repository.complete(with: glossDetail, at: 1)
        await waitFor {
            sut.productIDText == "PRODUCT ID: sku-gloss-regular"
        }
    }

    private func makeSUT(initialSlug: String, repository: ProductDetailRepositorySpy) -> ProductDetailViewController {
        ProductDetailUIComposer.make(
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
            media: [.sample(id: sku)],
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
                    media: [.sample(id: sku)],
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

    private func makeTextColorDetail(styleColorID: String, slug: String, selectedSKU: String) -> ProductDetail {
        ProductDetail(
            styleColorID: styleColorID,
            slug: slug,
            name: "Smooth Lounge Scoop Neck Maxi Dress",
            designerName: "SKIMS",
            description: "Description for \(styleColorID)",
            amberPoints: 428,
            media: [.sample(id: selectedSKU)],
            optionGroups: [
                ProductOptionGroup(
                    id: ProductOptionGroupID.color,
                    title: "Color",
                    displayStyle: .text,
                    isRequired: true,
                    values: [
                        ProductOptionValue(id: "218694515_16162", title: "Henna", swatchHex: "#68392C", isAvailable: true),
                        ProductOptionValue(id: "218694515_12393", title: "Raisin", swatchHex: "#524144", isAvailable: false),
                        ProductOptionValue(id: "218694515_11264", title: "Obsidian", swatchHex: "#3B3A3C", isAvailable: true)
                    ]
                ),
                ProductOptionGroup(
                    id: ProductOptionGroupID.size,
                    title: "Size",
                    displayStyle: .text,
                    isRequired: true,
                    values: [
                        ProductOptionValue(id: "73", title: "XXS", swatchHex: nil, isAvailable: true),
                        ProductOptionValue(id: "71", title: "L", swatchHex: nil, isAvailable: true)
                    ]
                )
            ],
            variants: [
                ProductVariant(
                    id: "218695046",
                    sku: "218695046",
                    optionValueIDs: [ProductOptionGroupID.color: styleColorID, ProductOptionGroupID.size: "73"],
                    description: "Description for \(styleColorID)",
                    media: [.sample(id: "218695046")],
                    price: Money(amount: 450, currencyCode: "AED"),
                    amberPoints: 428,
                    isAvailable: true
                ),
                ProductVariant(
                    id: selectedSKU,
                    sku: selectedSKU,
                    optionValueIDs: [ProductOptionGroupID.color: styleColorID, ProductOptionGroupID.size: "71"],
                    description: "Description for \(styleColorID)",
                    media: [.sample(id: selectedSKU)],
                    price: Money(amount: 450, currencyCode: "AED"),
                    amberPoints: 428,
                    isAvailable: true
                )
            ],
            initialSelectedValues: [
                ProductOptionGroupID.color: styleColorID,
                ProductOptionGroupID.size: "71"
            ],
            fallbackVariantID: selectedSKU,
            remoteSelectionSlugsByGroupID: [
                ProductOptionGroupID.color: [
                    "218694515_16162": "shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_16162",
                    "218694515_12393": "shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_12393",
                    "218694515_11264": "shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_11264"
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
            media: [.sample(id: "sku-s")],
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
                    media: [.sample(id: "sku-s")],
                    price: Money(amount: 3700, currencyCode: "AED"),
                    amberPoints: 3523,
                    isAvailable: true
                ),
                ProductVariant(
                    id: "sku-m",
                    sku: "sku-m",
                    optionValueIDs: [ProductOptionGroupID.size: "m"],
                    description: "Medium",
                    media: [.sample(id: "sku-m")],
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

    private func makeFinishDetail(
        finishID: String,
        slug: String,
        regularSKU: String,
        petiteSKU: String,
        petiteIsAvailable: Bool
    ) -> ProductDetail {
        ProductDetail(
            styleColorID: finishID,
            slug: slug,
            name: "Convertible Dress",
            designerName: "Racil",
            description: "Description for \(finishID)",
            amberPoints: 3523,
            media: [.sample(id: regularSKU)],
            optionGroups: [
                ProductOptionGroup(
                    id: TestOptionGroupID.finish,
                    title: "Finish",
                    displayStyle: .text,
                    isRequired: true,
                    values: [
                        ProductOptionValue(id: "matte", title: "Matte", swatchHex: nil, isAvailable: true),
                        ProductOptionValue(id: "gloss", title: "Gloss", swatchHex: nil, isAvailable: true)
                    ]
                ),
                ProductOptionGroup(
                    id: TestOptionGroupID.fit,
                    title: "Fit",
                    displayStyle: .text,
                    isRequired: true,
                    values: [
                        ProductOptionValue(id: "regular", title: "Regular", swatchHex: nil, isAvailable: true),
                        ProductOptionValue(id: "petite", title: "Petite", swatchHex: nil, isAvailable: petiteIsAvailable)
                    ]
                )
            ],
            variants: [
                ProductVariant(
                    id: regularSKU,
                    sku: regularSKU,
                    optionValueIDs: [TestOptionGroupID.finish: finishID, TestOptionGroupID.fit: "regular"],
                    description: "Regular \(finishID)",
                    media: [.sample(id: regularSKU)],
                    price: Money(amount: 3700, currencyCode: "AED"),
                    amberPoints: 3523,
                    isAvailable: true
                ),
                ProductVariant(
                    id: petiteSKU,
                    sku: petiteSKU,
                    optionValueIDs: [TestOptionGroupID.finish: finishID, TestOptionGroupID.fit: "petite"],
                    description: "Petite \(finishID)",
                    media: [.sample(id: petiteSKU)],
                    price: Money(amount: 3700, currencyCode: "AED"),
                    amberPoints: 3523,
                    isAvailable: petiteIsAvailable
                )
            ],
            initialSelectedValues: [
                TestOptionGroupID.finish: finishID,
                TestOptionGroupID.fit: "regular"
            ],
            fallbackVariantID: regularSKU,
            remoteSelectionSlugsByGroupID: [
                TestOptionGroupID.finish: [
                    "matte": "shop-finish-matte",
                    "gloss": "shop-finish-gloss"
                ]
            ]
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

private enum TestOptionGroupID {
    static let finish = "finish"
    static let fit = "fit"
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
