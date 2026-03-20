import Foundation

struct ResolvedOptionValue: Equatable {
    let value: ProductOptionValue
    let isSelected: Bool
    let isEnabled: Bool
}

struct ResolvedOptionGroup: Equatable {
    let id: String
    let title: String
    let displayStyle: ProductOptionDisplayStyle
    let isRequired: Bool
    let values: [ResolvedOptionValue]
}

struct SelectionState: Equatable {
    let selectedValueIDs: [String: String]
    let groups: [ResolvedOptionGroup]
    let selectedVariant: ProductVariant?
    let displayedVariant: ProductVariant
    let isAddToBagEnabled: Bool
}

struct SelectionStateResolver {
    func resolve(
        optionGroups: [ProductOptionGroup],
        variants: [ProductVariant],
        selectedValueIDs: [String: String],
        fallbackVariantID: String,
        externallySelectableValueIDsByGroupID: [String: Set<String>] = [:]
    ) -> SelectionState {
        let fallbackVariant = variants.first(where: { $0.id == fallbackVariantID }) ?? variants.first ?? ProductVariant(
            id: fallbackVariantID,
            sku: fallbackVariantID,
            optionValueIDs: [:],
            description: "",
            media: [],
            price: Money(amount: 0, currencyCode: "AED"),
            amberPoints: nil,
            isAvailable: false
        )

        let compatibleVariants = variants.filter { variant in
            selections(selectedValueIDs, match: variant.optionValueIDs)
        }

        let requiredGroupIDs = optionGroups.filter(\.isRequired).map(\.id)
        let allRequiredSelected = requiredGroupIDs.allSatisfy { selectedValueIDs[$0] != nil }
        let selectedVariant = allRequiredSelected ? compatibleVariants.first(where: { $0.isAvailable }) : nil
        let displayedVariant = selectedVariant ?? compatibleVariants.first(where: { $0.isAvailable }) ?? fallbackVariant

        let resolvedGroups = optionGroups.map { group in
            let values = group.values.map { value in
                let otherSelections = selectedValueIDs.filter { $0.key != group.id }
                let candidateSelections = otherSelections.merging([group.id: value.id]) { _, new in new }
                let isLocallyEnabled = variants.contains { variant in
                    variant.isAvailable && selections(candidateSelections, match: variant.optionValueIDs)
                }
                let isExternallySelectable = externallySelectableValueIDsByGroupID[group.id]?.contains(value.id) == true

                return ResolvedOptionValue(
                    value: value,
                    isSelected: selectedValueIDs[group.id] == value.id,
                    isEnabled: (isLocallyEnabled || isExternallySelectable) && value.isAvailable
                )
            }

            return ResolvedOptionGroup(
                id: group.id,
                title: group.title,
                displayStyle: group.displayStyle,
                isRequired: group.isRequired,
                values: values
            )
        }

        return SelectionState(
            selectedValueIDs: selectedValueIDs,
            groups: resolvedGroups,
            selectedVariant: selectedVariant,
            displayedVariant: displayedVariant,
            isAddToBagEnabled: selectedVariant?.isAvailable == true
        )
    }

    private func selections(_ selections: [String: String], match optionValueIDs: [String: String]) -> Bool {
        selections.allSatisfy { key, value in
            optionValueIDs[key] == value
        }
    }
}
