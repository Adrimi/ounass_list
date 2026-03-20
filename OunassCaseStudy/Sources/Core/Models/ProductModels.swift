import Foundation

struct Money: Equatable, Hashable {
    let amount: Decimal
    let currencyCode: String

    private static let aedFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AED"
        formatter.currencySymbol = "AED "
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_AE")
        return formatter
    }()

    var formatted: String {
        let formatter = currencyCode == "AED" ? Money.aedFormatter : {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencyCode = currencyCode
            f.maximumFractionDigits = 0
            f.minimumFractionDigits = 0
            return f
        }()
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currencyCode) \(amount)"
    }
}

struct MediaAsset: Equatable, Hashable {
    let id: String
    let url: URL
}

struct ProductListPage: Equatable {
    let products: [ProductSummary]
    let nextPagePath: String?
}

struct ProductSummary: Equatable, Hashable {
    let id: String
    let slug: String
    let name: String
    let designerName: String
    let price: Money
    let thumbnailURL: URL?
}

enum ProductOptionDisplayStyle: Equatable, Hashable {
    case swatch
    case text
}

struct ProductOptionValue: Equatable, Hashable {
    let id: String
    let title: String
    let swatchHex: String?
    let isAvailable: Bool
}

struct ProductOptionGroup: Equatable {
    let id: String
    let title: String
    let displayStyle: ProductOptionDisplayStyle
    let isRequired: Bool
    let values: [ProductOptionValue]
}

struct ProductVariant: Equatable {
    let id: String
    let sku: String
    let optionValueIDs: [String: String]
    let description: String
    let media: [MediaAsset]
    let price: Money
    let amberPoints: Int?
    let isAvailable: Bool
}

struct ProductDetail: Equatable {
    let styleColorID: String
    let slug: String
    let name: String
    let designerName: String
    let description: String
    let amberPoints: Int?
    let media: [MediaAsset]
    let optionGroups: [ProductOptionGroup]
    let variants: [ProductVariant]
    let initialSelectedValues: [String: String]
    let fallbackVariantID: String
    let remoteSelectionSlugsByGroupID: [String: [String: String]]
}

enum ProductOptionGroupID {
    static let color = "color"
    static let size = "size"
}
