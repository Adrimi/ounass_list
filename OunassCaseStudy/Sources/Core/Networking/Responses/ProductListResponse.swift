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
                thumbnailURL: OunassURLBuilder.websiteURL(path: item.thumbnail),
                hoverImageURL: OunassURLBuilder.websiteURL(path: item.hoverImage)
            )
        }

        let pagination = PaginationInfo(
            nextPagePath: plp.pagination.nextPage?.href,
            totalItems: plp.pagination.totalItems ?? items.count,
            currentSet: plp.pagination.currentSet ?? 1,
            viewSize: plp.pagination.viewSize ?? items.count
        )

        return ProductListPage(
            products: items,
            pagination: pagination,
            noFilterPath: plp.noFilterUrl
        )
    }
}
