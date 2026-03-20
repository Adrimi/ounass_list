import Testing
import Foundation
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
