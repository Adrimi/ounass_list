import UIKit

final class ProductListViewController: UIViewController {
    let collectionVC: CollectionViewController
    var onRefresh: (() -> Void)?

    init() {
        collectionVC = CollectionViewController(layout: Self.makeFlowLayout())
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ProductListPresenter.title
        view.backgroundColor = .appBackground
        setupCollectionViewController()
        onRefresh?()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFlowLayoutItemSize()
    }

    private func setupCollectionViewController() {
        addChild(collectionVC)
        collectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionVC.view)
        NSLayoutConstraint.activate([
            collectionVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionVC.didMove(toParent: self)

        collectionVC.collectionView.register(ProductListCell.self, forCellWithReuseIdentifier: ProductListCell.reuseIdentifier)
        collectionVC.onRefresh = { [weak self] in self?.onRefresh?() }
    }

    private static func makeFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        return layout
    }

    private func updateFlowLayoutItemSize() {
        guard let layout = collectionVC.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let columns: CGFloat = traitCollection.horizontalSizeClass == .compact ? 2 : 3
        let spacing = layout.minimumInteritemSpacing * (columns - 1)
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let width = view.bounds.width - spacing - insets
        let itemWidth = floor(width / columns)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.92)
    }
}
