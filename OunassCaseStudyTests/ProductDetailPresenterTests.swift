import Testing
import Foundation
@testable import OunassCaseStudy

struct ProductDetailPresenterTests {
    @Test func test_formatsDisplayedVariantAmberPoints() {
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

    @Test func test_fallsBackToDetailAmberPointsWhenVariantHasNone() {
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

    @Test func test_formatsDisplayedVariantProductID() {
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
            media: [.sample(id: "media")],
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
            media: [.sample(id: "media")],
            price: Money(amount: 3700, currencyCode: "AED"),
            amberPoints: amberPoints,
            isAvailable: true
        )
    }
}

private extension MediaAsset {
    static func sample(id: String) -> MediaAsset {
        MediaAsset(id: id, url: URL(string: "https://example.com/\(id).jpg")!)
    }
}
