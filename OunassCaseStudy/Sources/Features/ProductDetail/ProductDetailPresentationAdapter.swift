import Foundation

struct ProductDetailOptionSelection: Equatable {
    let groupID: String
    let valueID: String
}

protocol ProductDetailView: AnyObject {
    func display(_ viewModel: ProductDetailDisplayModel)
}

@MainActor
final class ProductDetailPresentationAdapter: ResourceView {
    typealias ResourceViewModel = ProductDetail

    private weak var view: ProductDetailView?
    private let resolver = SelectionStateResolver()

    var loadRequestedDetail: (() -> Void)?

    private(set) var requestedSlug: String
    private var currentDetail: ProductDetail?
    private var cachedDetails: [String: ProductDetail] = [:]
    private var selectedValueIDs: [String: String] = [:]
    private var pendingPreservedSelections: [String: String] = [:]

    init(requestedSlug: String, view: ProductDetailView) {
        self.requestedSlug = requestedSlug
        self.view = view
    }

    func didRequestLoad() {
        loadRequestedDetail?()
    }

    func didRequestRetry() {
        loadRequestedDetail?()
    }

    func didSelectOption(_ selection: ProductDetailOptionSelection) {
        guard let detail = currentDetail, selectedValueIDs[selection.groupID] != selection.valueID else {
            return
        }

        if let remoteSlug = detail.remoteSelectionSlugsByGroupID[selection.groupID]?[selection.valueID] {
            requestedSlug = remoteSlug
            pendingPreservedSelections = selectedValueIDs.merging([selection.groupID: selection.valueID]) { _, new in new }

            if let cachedDetail = cachedDetails[remoteSlug] {
                display(cachedDetail)
            } else {
                loadRequestedDetail?()
            }
            return
        }

        pendingPreservedSelections = [:]
        selectedValueIDs[selection.groupID] = selection.valueID
        render(detail)
    }

    nonisolated func display(_ detail: ProductDetail) {
        Task { @MainActor [weak self] in
            self?.didLoad(detail)
        }
    }

    private func didLoad(_ detail: ProductDetail) {
        cachedDetails[detail.slug] = detail
        currentDetail = detail
        requestedSlug = detail.slug
        selectedValueIDs = mergedSelectedValueIDs(for: detail, preserving: pendingPreservedSelections)
        pendingPreservedSelections = [:]
        render(detail)
    }

    private func mergedSelectedValueIDs(
        for detail: ProductDetail,
        preserving preservedSelections: [String: String]
    ) -> [String: String] {
        var values = detail.initialSelectedValues

        preservedSelections.forEach { groupID, valueID in
            guard detail.optionGroups.contains(where: { group in
                group.id == groupID && group.values.contains(where: { $0.id == valueID && $0.isAvailable })
            }) else {
                return
            }

            values[groupID] = valueID
        }

        return values
    }

    private func render(_ detail: ProductDetail) {
        let selectionState = resolver.resolve(
            optionGroups: detail.optionGroups,
            variants: detail.variants,
            selectedValueIDs: selectedValueIDs,
            fallbackVariantID: detail.fallbackVariantID,
            externallySelectableValueIDsByGroupID: detail.remoteSelectionSlugsByGroupID.mapValues { Set($0.keys) }
        )

        view?.display(ProductDetailPresenter.map(detail, selectionState: selectionState))
    }
}
