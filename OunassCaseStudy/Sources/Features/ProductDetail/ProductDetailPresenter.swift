import Foundation

struct ProductDetailDisplayModel {
    let title: String
    let designerName: String
    let productName: String
    let priceText: String
    let amberPointsText: String?
    let productCodeText: String
    let descriptionText: String?
    let media: [MediaAsset]
    let optionGroups: [ResolvedOptionGroup]
    let isAddToBagEnabled: Bool
}

final class ProductDetailPresenter {
    static func map(_ detail: ProductDetail, selectionState: SelectionState) -> ProductDetailDisplayModel {
        ProductDetailDisplayModel(
            title: detail.name,
            designerName: detail.designerName,
            productName: detail.name,
            priceText: selectionState.displayedVariant.price.formatted,
            amberPointsText: selectionState.displayedVariant.amberPoints?.formatted ?? detail.amberPoints?.formatted,
            productCodeText: "Product code: \(selectionState.displayedVariant.sku)",
            descriptionText: selectionState.displayedVariant.description.isEmpty ? detail.description : selectionState.displayedVariant.description,
            media: selectionState.displayedVariant.media.isEmpty ? detail.media : selectionState.displayedVariant.media,
            optionGroups: selectionState.groups,
            isAddToBagEnabled: selectionState.isAddToBagEnabled
        )
    }
}
