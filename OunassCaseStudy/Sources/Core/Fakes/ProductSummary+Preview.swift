#if DEBUG
import Foundation

extension ProductSummary {
    static func fake() -> ProductSummary {
        ProductSummary(
            id: "fake-001",
            slug: "gucci-t-shirt",
            name: "GG Cotton T-shirt",
            designerName: "Gucci",
            price: Money(amount: 650, currencyCode: "AED"),
            thumbnailURL: URL(string: "fake://preview")
        )
    }
}
#endif
