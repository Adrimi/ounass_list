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
        #expect(page.pagination.nextPagePath == "/women/clothing?fh_start_index=48")
    }

    @Test func testDetailResponseDecodesVariantOptions() throws {
        let response = try decoder.decode(ProductDetailResponse.self, from: TestFixtures.detailJSON)
        let detail = response.toDomain()

        #expect(detail.name == "Lee Fringed Kaftan")
        #expect(detail.optionGroups.map { $0.id } == [ProductOptionGroupID.color, ProductOptionGroupID.size])
        #expect(detail.variants.count == 3)
        #expect(detail.initialSelectedValues[ProductOptionGroupID.color] == "219370859_27")
        #expect(detail.remoteSelectionSlugsByGroupID[ProductOptionGroupID.color]?["219370859_14"] == "shop-racil-lee-fringed-kaftan-for-women-219370859_14")
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
