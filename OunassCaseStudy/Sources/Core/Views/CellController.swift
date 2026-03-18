import UIKit

protocol CellSizeProvider {
    func size(in bounds: CGRect) -> CGSize
}

struct CellController: Hashable {
    let id: AnyHashable
    let dataSource: UICollectionViewDataSource
    let delegate: UICollectionViewDelegate?
    let dataSourcePrefetching: UICollectionViewDataSourcePrefetching?

    init(id: AnyHashable, _ dataSource: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDataSourcePrefetching) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
    }

    init(id: AnyHashable, _ dataSource: UICollectionViewDataSource & UICollectionViewDelegate) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = nil
    }

    init(id: AnyHashable, _ dataSource: UICollectionViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefetching = nil
    }

    static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
