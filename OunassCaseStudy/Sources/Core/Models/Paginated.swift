struct Paginated<Item> {
    let items: [Item]
    let loadMore: (() async throws -> Paginated<Item>)?

    init(items: [Item], loadMore: (() async throws -> Paginated<Item>)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
