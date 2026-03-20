import Foundation

struct ProductDetailDisplayModel {
    let designerName: String
    let productName: String
    let priceText: String
    let amberPointsText: String?
    let descriptionText: String?
    let media: [MediaAsset]
    let optionGroups: [ResolvedOptionGroup]
    let isAddToBagEnabled: Bool
}

final class ProductDetailPresenter {
    static func map(_ detail: ProductDetail, selectionState: SelectionState) -> ProductDetailDisplayModel {
        ProductDetailDisplayModel(
            designerName: detail.designerName,
            productName: detail.name,
            priceText: selectionState.displayedVariant.price.formatted,
            amberPointsText: amberPointsText(
                displayedVariantValue: selectionState.displayedVariant.amberPoints,
                detailValue: detail.amberPoints
            ),
            descriptionText: selectionState.displayedVariant.description.isEmpty ? detail.description : selectionState.displayedVariant.description,
            media: selectionState.displayedVariant.media.isEmpty ? detail.media : selectionState.displayedVariant.media,
            optionGroups: selectionState.groups,
            isAddToBagEnabled: selectionState.isAddToBagEnabled
        )
    }

    private static func amberPointsText(displayedVariantValue: Int?, detailValue: Int?) -> String? {
        (displayedVariantValue ?? detailValue).map { "\($0) Amber points" }
    }
}
