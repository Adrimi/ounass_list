import Testing
import Foundation
@testable import OunassCaseStudy

struct SelectionStateResolverTests {
    private let resolver = SelectionStateResolver()

    @Test func testSizeOnlyProductRequiresSizeSelection() {
        let state = resolver.resolve(
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
                ProductVariant(id: "sku-s", sku: "sku-s", optionValueIDs: [ProductOptionGroupID.size: "s"], description: "Small", media: [.sample(id: "s")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true),
                ProductVariant(id: "sku-m", sku: "sku-m", optionValueIDs: [ProductOptionGroupID.size: "m"], description: "Medium", media: [.sample(id: "m")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true)
            ],
            selectedValueIDs: [:],
            fallbackVariantID: "sku-s"
        )

        #expect(!state.isAddToBagEnabled)
        #expect(state.displayedVariant.sku == "sku-s")
    }

    @Test func testColorOnlyProductIsReadyWhenCurrentColorIsSelected() {
        let state = resolver.resolve(
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
                ProductVariant(id: "yellow", sku: "sku-yellow", optionValueIDs: [ProductOptionGroupID.color: "yellow"], description: "Yellow variant", media: [.sample(id: "yellow")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true),
                ProductVariant(id: "blue", sku: "sku-blue", optionValueIDs: [ProductOptionGroupID.color: "blue"], description: "Blue variant", media: [.sample(id: "blue")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true)
            ],
            selectedValueIDs: [ProductOptionGroupID.color: "yellow"],
            fallbackVariantID: "yellow"
        )

        #expect(state.isAddToBagEnabled)
        #expect(state.selectedVariant?.sku == "sku-yellow")
        #expect(state.displayedVariant.description == "Yellow variant")
    }

    @Test func testProductWithoutOptionsIsImmediatelySelectable() {
        let state = resolver.resolve(
            optionGroups: [],
            variants: [
                ProductVariant(id: "single", sku: "single", optionValueIDs: [:], description: "Only item", media: [.sample(id: "single")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true)
            ],
            selectedValueIDs: [:],
            fallbackVariantID: "single"
        )

        #expect(state.isAddToBagEnabled)
        #expect(state.displayedVariant.sku == "single")
    }

    @Test func testSelectingColorConstrictsSizesAndChangesDisplayedVariant() {
        let optionGroups = [
            ProductOptionGroup(
                id: ProductOptionGroupID.color,
                title: "Color",
                displayStyle: .swatch,
                isRequired: true,
                values: [
                    ProductOptionValue(id: "yellow", title: "Yellow", swatchHex: "#FEE877", isAvailable: true),
                    ProductOptionValue(id: "blue", title: "Blue", swatchHex: "#5E96E1", isAvailable: true)
                ]
            ),
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
        ]

        let variants = [
            ProductVariant(id: "yellow-s", sku: "yellow-s", optionValueIDs: [ProductOptionGroupID.color: "yellow", ProductOptionGroupID.size: "s"], description: "Yellow S", media: [.sample(id: "yellow-s")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true),
            ProductVariant(id: "yellow-m", sku: "yellow-m", optionValueIDs: [ProductOptionGroupID.color: "yellow", ProductOptionGroupID.size: "m"], description: "Yellow M", media: [.sample(id: "yellow-m")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true),
            ProductVariant(id: "blue-m", sku: "blue-m", optionValueIDs: [ProductOptionGroupID.color: "blue", ProductOptionGroupID.size: "m"], description: "Blue M", media: [.sample(id: "blue-m")], price: Money(amount: 100, currencyCode: "AED"), amberPoints: nil, isAvailable: true)
        ]

        let state = resolver.resolve(
            optionGroups: optionGroups,
            variants: variants,
            selectedValueIDs: [ProductOptionGroupID.color: "blue", ProductOptionGroupID.size: "m"],
            fallbackVariantID: "yellow-s"
        )

        #expect(state.isAddToBagEnabled)
        #expect(state.displayedVariant.sku == "blue-m")
        #expect(state.displayedVariant.description == "Blue M")
        #expect(state.displayedVariant.media.first?.id == "blue-m")

        let sizeGroup = state.groups.first(where: { $0.id == ProductOptionGroupID.size })
        let sizeS = sizeGroup?.values.first(where: { $0.value.id == "s" })
        #expect(sizeS?.isEnabled == false)
    }
}

private extension MediaAsset {
    static func sample(id: String) -> MediaAsset {
        MediaAsset(id: id, url: URL(string: "https://example.com/\(id).jpg")!)
    }
}
