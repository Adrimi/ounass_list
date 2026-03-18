import UIKit

final class ProductDetailViewController: UIViewController {
    private let viewModel: ProductDetailViewModel
    private let imageLoader: ImageLoader

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let infoStack = UIStackView()
    private let optionsStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = ErrorPlaceholderView()
    private let mediaCarouselView: MediaCarouselView
    private let designerLabel = UILabel()
    private let productNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let amberPointsLabel = UILabel()
    private let productCodeLabel = UILabel()
    private let addToBagButton = UIButton(type: .system)
    private let descriptionHeaderLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var optionGroupViews: [OptionGroupView] = []

    init(viewModel: ProductDetailViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        self.mediaCarouselView = MediaCarouselView(imageLoader: imageLoader)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bindViewModel()
        viewModel.loadIfNeeded()
    }

    private func configureView() {
        view.backgroundColor = .appBackground
        setupViewHierarchy()
        setupLayout()
        styleLabels()
        styleButton()

        errorView.isHidden = true
        errorView.onAction = { [weak self] in
            self?.viewModel.retry()
        }
    }

    private func setupViewHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 24
        infoStack.axis = .vertical
        infoStack.spacing = 8
        optionsStack.axis = .vertical
        optionsStack.spacing = 20

        [designerLabel, productNameLabel, priceLabel, amberPointsLabel, productCodeLabel].forEach(infoStack.addArrangedSubview)
        [mediaCarouselView, infoStack, optionsStack, addToBagButton, descriptionHeaderLabel, descriptionLabel].forEach(contentStack.addArrangedSubview)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            mediaCarouselView.heightAnchor.constraint(equalToConstant: 420),
            addToBagButton.heightAnchor.constraint(equalToConstant: 54),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            errorView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func styleLabels() {
        designerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        designerLabel.textColor = UIColor(white: 0.34, alpha: 1)
        designerLabel.numberOfLines = 0

        productNameLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        productNameLabel.textColor = UIColor(white: 0.11, alpha: 1)
        productNameLabel.numberOfLines = 0

        priceLabel.font = .systemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = UIColor(white: 0.09, alpha: 1)

        amberPointsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        amberPointsLabel.textColor = UIColor(red: 0.66, green: 0.42, blue: 0.16, alpha: 1)
        amberPointsLabel.numberOfLines = 0

        productCodeLabel.font = .systemFont(ofSize: 13, weight: .regular)
        productCodeLabel.textColor = UIColor(white: 0.42, alpha: 1)

        descriptionHeaderLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        descriptionHeaderLabel.textColor = UIColor(white: 0.12, alpha: 1)
        descriptionHeaderLabel.text = "Editor's advice"

        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor(white: 0.2, alpha: 1)
        descriptionLabel.numberOfLines = 0
    }

    private func styleButton() {
        addToBagButton.backgroundColor = UIColor(white: 0.11, alpha: 1)
        addToBagButton.setTitleColor(.white, for: .normal)
        addToBagButton.setTitle("Add to Bag", for: .normal)
        addToBagButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addToBagButton.layer.cornerRadius = 16
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }
    }

    private func render(state: ProductDetailViewState) {
        title = state.title
        designerLabel.text = state.designerName?.uppercased()
        productNameLabel.text = state.productName
        priceLabel.text = state.priceText
        amberPointsLabel.text = state.amberPointsText
        amberPointsLabel.isHidden = state.amberPointsText == nil
        productCodeLabel.text = state.productCodeText
        descriptionLabel.text = state.descriptionText
        descriptionHeaderLabel.isHidden = state.descriptionText?.isEmpty ?? true
        descriptionLabel.isHidden = state.descriptionText?.isEmpty ?? true
        mediaCarouselView.render(media: state.media)
        renderOptionGroups(state.optionGroups)
        addToBagButton.isEnabled = state.addToBagEnabled
        addToBagButton.alpha = state.addToBagEnabled ? 1 : 0.45

        if state.isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        let shouldShowError = state.productName == nil && state.errorMessage != nil && state.isLoading == false
        errorView.isHidden = shouldShowError == false
        scrollView.isHidden = shouldShowError
        if shouldShowError {
            errorView.render(
                title: "Couldn’t load product",
                message: state.errorMessage ?? "Please try again."
            )
        }
    }

    private func renderOptionGroups(_ groups: [ResolvedOptionGroup]) {
        optionGroupViews.forEach { view in
            optionsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        optionGroupViews.removeAll()

        groups.forEach { group in
            let groupView = OptionGroupView()
            groupView.render(group: group) { [weak self] valueID in
                self?.viewModel.selectOption(groupID: group.id, valueID: valueID)
            }
            optionsStack.addArrangedSubview(groupView)
            optionGroupViews.append(groupView)
        }
    }
}


private final class MediaCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    private let pageControl = UIPageControl()
    private var media: [MediaAsset] = []

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(white: 0.1, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(white: 0.74, alpha: 1)

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
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MediaCarouselCell.reuseIdentifier,
                for: indexPath
            ) as? MediaCarouselCell
        else {
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

private final class MediaCarouselCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaCarouselCell"

    private let imageView = UIImageView()
    private var imageLoadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = UIColor(white: 0.92, alpha: 1)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = nil
    }

    func configure(with media: MediaAsset, imageLoader: ImageLoader) {
        imageLoadTask?.cancel()
        imageLoadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            if let image = try? await imageLoader.loadImage(from: media.url) {
                self.imageView.image = image
            }
        }
    }
}

private final class OptionGroupView: UIView {
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.14, alpha: 1)

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill

        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(group: ResolvedOptionGroup, onSelection: @escaping (String) -> Void) {
        titleLabel.text = group.title

        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        group.values.forEach { value in
            let button = OptionValueButton(style: group.displayStyle)
            button.apply(resolvedValue: value)
            button.onTap = {
                onSelection(value.value.id)
            }
            stackView.addArrangedSubview(button)
        }
    }
}

private final class OptionValueButton: UIControl {
    var onTap: (() -> Void)?

    private let style: ProductOptionDisplayStyle
    private let stackView = UIStackView()
    private let swatchView = UIView()
    private let titleLabel = UILabel()

    init(style: ProductOptionDisplayStyle) {
        self.style = style
        super.init(frame: .zero)

        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
        backgroundColor = .white

        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        swatchView.translatesAutoresizingMaskIntoConstraints = false
        swatchView.layer.cornerRadius = 10
        swatchView.layer.borderWidth = 1
        swatchView.layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.14, alpha: 1)

        addSubview(stackView)
        stackView.addArrangedSubview(swatchView)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            swatchView.widthAnchor.constraint(equalToConstant: 20),
            swatchView.heightAnchor.constraint(equalToConstant: 20)
        ])

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(resolvedValue: ResolvedOptionValue) {
        titleLabel.text = resolvedValue.value.title
        swatchView.isHidden = style != .swatch

        if style == .swatch {
            swatchView.backgroundColor = UIColor(hex: resolvedValue.value.swatchHex) ?? UIColor(white: 0.95, alpha: 1)
        }

        isEnabled = resolvedValue.isEnabled
        alpha = resolvedValue.isEnabled ? 1 : 0.35

        if resolvedValue.isSelected {
            layer.borderColor = UIColor(white: 0.1, alpha: 1).cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
            layer.borderWidth = 1
        }
    }

    @objc private func handleTap() {
        guard isEnabled else {
            return
        }
        onTap?()
    }
}

