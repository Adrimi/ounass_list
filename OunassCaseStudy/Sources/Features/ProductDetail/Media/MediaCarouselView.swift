import UIKit

final class MediaCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    private let flowLayout = UICollectionViewFlowLayout()

    private lazy var collectionView: UICollectionView = {
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(MediaCarouselCell.self, forCellWithReuseIdentifier: MediaCarouselCell.reuseIdentifier)
        return collectionView
    }()

    let linePageControl = LinePageControl()

    private var cellControllers: [CellController] = []

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = bounds.size
    }

    func display(_ cellControllers: [CellController], pageCount: Int) {
        self.cellControllers = cellControllers
        linePageControl.numberOfPages = pageCount
        linePageControl.isHidden = pageCount <= 1
        linePageControl.currentPage = min(linePageControl.currentPage, max(pageCount - 1, 0))
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellControllers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cellControllers[indexPath.item].dataSource.collectionView(collectionView, cellForItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(at: indexPath)?.delegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(at: indexPath)?.delegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(at: indexPath)?.dataSourcePrefetching?.collectionView(collectionView, prefetchItemsAt: [indexPath])
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(at: indexPath)?.dataSourcePrefetching?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        linePageControl.currentPage = page
    }

    private func cellController(at indexPath: IndexPath) -> CellController? {
        guard cellControllers.indices.contains(indexPath.item) else { return nil }
        return cellControllers[indexPath.item]
    }
}
