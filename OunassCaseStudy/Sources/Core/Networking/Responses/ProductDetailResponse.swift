import Foundation

struct ProductDetailResponse: Decodable {
    let pdp: ProductDetailData

    func toDomain() -> ProductDetail {
        let mediaItems = pdp.media ?? []
        let colorItems = pdp.colors ?? []
        let sizeItems = pdp.sizes ?? []

        let media = mediaItems.compactMap { item in
            OunassURLBuilder.imageURL(path: item.src).map {
                MediaAsset(id: item.src, url: $0)
            }
        }

        let fallbackMedia: [MediaAsset]
        if media.isEmpty, let thumbnailURL = OunassURLBuilder.websiteURL(path: pdp.thumbnail) {
            fallbackMedia = [MediaAsset(id: pdp.styleColorId, url: thumbnailURL)]
        } else {
            fallbackMedia = media
        }

        let colorValues = colorItems.compactMap { option -> ProductOptionValue? in
            guard let colorID = option.styleColorId else { return nil }
            return ProductOptionValue(
                id: colorID,
                title: option.label ?? "Color",
                swatchHex: option.hex,
                previewImageURL: OunassURLBuilder.websiteURL(path: option.thumbnail),
                isAvailable: option.isInStock ?? true
            )
        }

        let sizeValues = sizeItems.map { size in
            ProductOptionValue(
                id: String(size.sizeCodeId),
                title: size.sizeCode,
                swatchHex: nil,
                previewImageURL: nil,
                isAvailable: !(size.disabled ?? false) && (size.stock ?? 0) > 0
            )
        }

        var optionGroups: [ProductOptionGroup] = []
        var initialSelectedValues: [String: String] = [:]
        var remoteSelectionSlugsByGroupID: [String: [String: String]] = [:]

        if colorValues.count > 1 {
            optionGroups.append(
                ProductOptionGroup(
                    id: ProductOptionGroupID.color,
                    title: "Color",
                    displayStyle: .swatch,
                    isRequired: true,
                    values: colorValues
                )
            )
        }

        if let selectedColorID = pdp.selectedColor?.styleColorId ?? colorValues.first?.id {
            initialSelectedValues[ProductOptionGroupID.color] = selectedColorID
        }

        if sizeValues.count > 1 {
            optionGroups.append(
                ProductOptionGroup(
                    id: ProductOptionGroupID.size,
                    title: "Size",
                    displayStyle: .text,
                    isRequired: true,
                    values: sizeValues
                )
            )
        } else if let onlySize = sizeValues.first, onlySize.isAvailable {
            initialSelectedValues[ProductOptionGroupID.size] = onlySize.id
        }

        if colorItems.isEmpty == false {
            remoteSelectionSlugsByGroupID[ProductOptionGroupID.color] = Dictionary(
                uniqueKeysWithValues: colorItems.compactMap { option in
                    guard
                        let id = option.styleColorId,
                        let slug = OunassURLBuilder.slug(from: option.url)
                    else {
                        return nil
                    }

                    return (id, slug)
                }
            )
        }

        let variants = makeVariants(
            detail: pdp,
            media: fallbackMedia,
            selectedColorID: initialSelectedValues[ProductOptionGroupID.color]
        )

        let fallbackVariantID = variants.first(where: { $0.sku == pdp.visibleSku })?.id ?? variants.first?.id ?? pdp.visibleSku

        return ProductDetail(
            styleColorID: pdp.styleColorId,
            slug: pdp.slug,
            visibleSKU: pdp.visibleSku,
            name: pdp.name,
            designerName: pdp.designerCategoryName,
            description: pdp.descriptionText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            price: Money(amount: pdp.price.value, currencyCode: "AED"),
            amberPoints: pdp.amberPoints.map(AmberPoints.init(value:)),
            media: fallbackMedia,
            optionGroups: optionGroups,
            variants: variants,
            initialSelectedValues: initialSelectedValues,
            fallbackVariantID: fallbackVariantID,
            remoteSelectionSlugsByGroupID: remoteSelectionSlugsByGroupID
        )
    }

    private func makeVariants(
        detail: ProductDetailData,
        media: [MediaAsset],
        selectedColorID: String?
    ) -> [ProductVariant] {
        let baseDescription = detail.descriptionText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let basePrice = Money(amount: detail.price.value, currencyCode: "AED")
        let amberPoints = detail.amberPoints.map(AmberPoints.init(value:))
        let currentColorID = selectedColorID ?? detail.styleColorId

        let colors = detail.colors ?? []
        let sizes = detail.sizes ?? []

        if sizes.isEmpty {
            var selections: [String: String] = [:]
            if colors.isEmpty == false {
                selections[ProductOptionGroupID.color] = currentColorID
            }

            return [
                ProductVariant(
                    id: detail.visibleSku,
                    sku: detail.visibleSku,
                    optionValueIDs: selections,
                    description: baseDescription,
                    media: media,
                    price: basePrice,
                    amberPoints: amberPoints,
                    isAvailable: !(detail.outOfStock ?? false)
                )
            ]
        }

        return sizes.map { size in
            var selections: [String: String] = [:]
            if colors.isEmpty == false {
                selections[ProductOptionGroupID.color] = currentColorID
            }
            selections[ProductOptionGroupID.size] = String(size.sizeCodeId)

            return ProductVariant(
                id: size.sku,
                sku: size.sku,
                optionValueIDs: selections,
                description: baseDescription,
                media: media,
                price: Money(amount: size.price?.value ?? detail.price.value, currencyCode: "AED"),
                amberPoints: size.amberPoints.map(AmberPoints.init(value:)) ?? amberPoints,
                isAvailable: !(size.disabled ?? false) && (size.stock ?? 0) > 0
            )
        }
    }
}
