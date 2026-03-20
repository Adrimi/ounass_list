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
        let colorGroup = try #require(detail.optionGroups.first(where: { $0.id == ProductOptionGroupID.color }))

        #expect(detail.name == "Lee Fringed Kaftan")
        #expect(detail.optionGroups.map { $0.id } == [ProductOptionGroupID.color, ProductOptionGroupID.size])
        #expect(colorGroup.displayStyle == .swatch)
        #expect(detail.variants.count == 3)
        #expect(detail.initialSelectedValues[ProductOptionGroupID.color] == "219370859_27")
        #expect(detail.remoteSelectionSlugsByGroupID[ProductOptionGroupID.color]?["219370859_14"] == "shop-racil-lee-fringed-kaftan-for-women-219370859_14")
        #expect(detail.variants.first?.price.amount == 3700)
    }

    @Test func testDetailResponseDecodesMultiColorTextSelectorAndRemoteAvailability() throws {
        let response = try decoder.decode(ProductDetailResponse.self, from: TestFixtures.textColorDetailJSON)
        let detail = response.toDomain()
        let colorGroup = try #require(detail.optionGroups.first(where: { $0.id == ProductOptionGroupID.color }))
        let selectionState = SelectionStateResolver().resolve(
            optionGroups: detail.optionGroups,
            variants: detail.variants,
            selectedValueIDs: detail.initialSelectedValues,
            fallbackVariantID: detail.fallbackVariantID,
            externallySelectableValueIDsByGroupID: detail.remoteSelectionSlugsByGroupID.mapValues { Set($0.keys) }
        )
        let resolvedColorGroup = try #require(selectionState.groups.first(where: { $0.id == ProductOptionGroupID.color }))
        let raisinValue = try #require(resolvedColorGroup.values.first(where: { $0.value.id == "218694515_12393" }))
        let obsidianValue = try #require(resolvedColorGroup.values.first(where: { $0.value.id == "218694515_11264" }))

        #expect(response.pdp.shouldShowSwatchOptions == false)
        #expect(detail.optionGroups.map(\.id) == [ProductOptionGroupID.color, ProductOptionGroupID.size])
        #expect(colorGroup.displayStyle == .text)
        #expect(detail.initialSelectedValues[ProductOptionGroupID.color] == "218694515_16162")
        #expect(detail.remoteSelectionSlugsByGroupID[ProductOptionGroupID.color]?["218694515_11264"] == "shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_11264")
        #expect(obsidianValue.isEnabled)
        #expect(!raisinValue.isEnabled)
    }

    @Test func testDetailResponseHandlesMissingOptionalFields() throws {
        let response = try decoder.decode(ProductDetailResponse.self, from: TestFixtures.minimalDetailJSON)
        let detail = response.toDomain()

        #expect(detail.variants.count == 1)
        #expect(detail.optionGroups.isEmpty)
        #expect(detail.amberPoints == nil)
        #expect(detail.description == "")
    }
}
