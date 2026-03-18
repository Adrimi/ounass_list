import Foundation

struct ProductDetailViewState: Equatable {
    let title: String?
    let designerName: String?
    let productName: String?
    let priceText: String?
    let amberPointsText: String?
    let productCodeText: String?
    let descriptionText: String?
    let media: [MediaAsset]
    let optionGroups: [ResolvedOptionGroup]
    let addToBagEnabled: Bool
    let isLoading: Bool
    let errorMessage: String?
}

@MainActor
final class ProductDetailViewModel {
    var onStateChange: ((ProductDetailViewState) -> Void)?

    private let initialSlug: String
    private let repository: ProductDetailRepositoryProtocol
    private let resolver = SelectionStateResolver()

    private var currentDetail: ProductDetail?
    private var cachedDetails: [String: ProductDetail] = [:]
    private var selectedValueIDs: [String: String] = [:]
    private var isLoading = false
    private var errorMessage: String?

    init(initialSlug: String, repository: ProductDetailRepositoryProtocol) {
        self.initialSlug = initialSlug
        self.repository = repository
    }

    func loadIfNeeded() {
        guard currentDetail == nil, isLoading == false else {
            publishState()
            return
        }

        fetchDetail(slug: initialSlug, preservingSizeID: nil)
    }

    func retry() {
        fetchDetail(slug: currentDetail?.slug ?? initialSlug, preservingSizeID: selectedValueIDs[ProductOptionGroupID.size])
    }

    func selectOption(groupID: String, valueID: String) {
        guard let currentDetail else {
            return
        }

        if
            let remoteSlug = currentDetail.remoteSelectionSlugsByGroupID[groupID]?[valueID],
            selectedValueIDs[groupID] != valueID
        {
            if let cachedDetail = cachedDetails[valueID] {
                let previousSizeID = selectedValueIDs[ProductOptionGroupID.size]
                self.currentDetail = cachedDetail
                selectedValueIDs = cachedDetail.initialSelectedValues
                if
                    let previousSizeID,
                    let sizeGroup = cachedDetail.optionGroups.first(where: { $0.id == ProductOptionGroupID.size }),
                    sizeGroup.values.contains(where: { $0.id == previousSizeID && $0.isAvailable })
                {
                    selectedValueIDs[ProductOptionGroupID.size] = previousSizeID
                }
                errorMessage = nil
                publishState()
                return
            }

            fetchDetail(slug: remoteSlug, preservingSizeID: selectedValueIDs[ProductOptionGroupID.size])
            return
        }

        selectedValueIDs[groupID] = valueID
        errorMessage = nil
        publishState()
    }

    private func fetchDetail(slug: String, preservingSizeID: String?) {
        isLoading = true
        errorMessage = nil
        publishState()

        Task {
            do {
                let detail = try await repository.fetchDetail(slug: slug)
                cachedDetails[detail.styleColorID] = detail
                currentDetail = detail
                selectedValueIDs = detail.initialSelectedValues

                if
                    let preservingSizeID,
                    let sizeGroup = detail.optionGroups.first(where: { $0.id == ProductOptionGroupID.size }),
                    sizeGroup.values.contains(where: { $0.id == preservingSizeID && $0.isAvailable })
                {
                    selectedValueIDs[ProductOptionGroupID.size] = preservingSizeID
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
            publishState()
        }
    }

    private func publishState() {
        guard let currentDetail else {
            onStateChange?(
                ProductDetailViewState(
                    title: nil,
                    designerName: nil,
                    productName: nil,
                    priceText: nil,
                    amberPointsText: nil,
                    productCodeText: nil,
                    descriptionText: nil,
                    media: [],
                    optionGroups: [],
                    addToBagEnabled: false,
                    isLoading: isLoading,
                    errorMessage: errorMessage
                )
            )
            return
        }

        let selectionState = resolver.resolve(
            optionGroups: currentDetail.optionGroups,
            variants: currentDetail.variants,
            selectedValueIDs: selectedValueIDs,
            fallbackVariantID: currentDetail.fallbackVariantID
        )

        onStateChange?(
            ProductDetailViewState(
                title: currentDetail.name,
                designerName: currentDetail.designerName,
                productName: currentDetail.name,
                priceText: selectionState.displayedVariant.price.formatted,
                amberPointsText: selectionState.displayedVariant.amberPoints?.formatted ?? currentDetail.amberPoints?.formatted,
                productCodeText: "Product code: \(selectionState.displayedVariant.sku)",
                descriptionText: selectionState.displayedVariant.description.isEmpty ? currentDetail.description : selectionState.displayedVariant.description,
                media: selectionState.displayedVariant.media.isEmpty ? currentDetail.media : selectionState.displayedVariant.media,
                optionGroups: selectionState.groups,
                addToBagEnabled: selectionState.isAddToBagEnabled,
                isLoading: isLoading,
                errorMessage: errorMessage
            )
        )
    }
}
