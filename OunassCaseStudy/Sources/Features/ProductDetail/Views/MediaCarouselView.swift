import UIKit

final class MediaCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let imageLoader: ImageLoader
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
        collectionView.register(MediaCarouselCell.self, forCellWithReuseIdentifier: MediaCarouselCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .primary
        pc.pageIndicatorTintColor = .surfaceVariant
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private var media: [MediaAsset] = []

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        addSubview(pageControl)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = bounds.size
    }

    func render(media: [MediaAsset]) {
        self.media = media
        pageControl.numberOfPages = media.count
        pageControl.isHidden = media.count <= 1
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        media.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MediaCarouselCell.reuseIdentifier,
            for: indexPath
        ) as? MediaCarouselCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: media[indexPath.item], imageLoader: imageLoader)
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        pageControl.currentPage = page
    }
}
