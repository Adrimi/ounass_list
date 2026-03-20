import Foundation

struct ProductListResponse: Decodable {
    let plp: ProductListContainerResponse

    func toDomain() -> ProductListPage {
        let items = plp.styleColors.map { item in
            ProductSummary(
                id: item.styleColorId,
                slug: item.slug,
                name: item.name,
                designerName: item.designerCategoryName,
                price: Money(amount: item.price.value, currencyCode: "AED"),
                thumbnailURL: OunassURLBuilder.websiteURL(path: item.thumbnail)
            )
        }

        return ProductListPage(
            products: items,
            nextPagePath: plp.pagination.nextPage?.href
        )
    }
}
