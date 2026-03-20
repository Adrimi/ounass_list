import UIKit

final class ProductDetailViewController: UIViewController {
    private let repository: ProductDetailRepositoryProtocol
    private var requestedSlug: String

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.contentInsetAdjustmentBehavior = .automatic
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 24
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var optionsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var errorBanner: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onHide = { [weak self] in
            guard let self else { return }
            self.setupLoadAdapter(slug: self.requestedSlug)
            self.loadAdapter.loadResource()
        }
        return view
    }()

    private let mediaCarouselView: MediaCarouselView
    private let mediaCarouselViewAdapter: MediaCarouselViewAdapter

    private lazy var brandLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .serif(size: 32, weight: .light)
        label.textColor = .onSurface
        label.numberOfLines = 0
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 24)
        label.textColor = .onSurface
        return label
    }()

    private lazy var amberPointsLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 12)
        label.textColor = .secondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var priceAmberStack: UIStackView = {
        let separatorView = UIView()
        separatorView.backgroundColor = .surfaceVariant
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .secondary
        starIcon.contentMode = .scaleAspectFit
        starIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            separatorView.widthAnchor.constraint(equalToConstant: 1),
            separatorView.heightAnchor.constraint(equalToConstant: 16),
            starIcon.widthAnchor.constraint(equalToConstant: 12),
            starIcon.heightAnchor.constraint(equalToConstant: 12)
        ])

        let amberGroup = UIStackView(arrangedSubviews: [starIcon, amberPointsLabel])
        amberGroup.axis = .horizontal
        amberGroup.spacing = 4
        amberGroup.alignment = .center

        let sv = UIStackView(arrangedSubviews: [priceLabel, separatorView, amberGroup])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        return sv
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 15)
        label.textColor = .onSurface
        label.numberOfLines = 3
        return label
    }()

    private lazy var productIDLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .kern: CGFloat(1.5),
            .font: UIFont.sans(size: 10, weight: .medium),
            .foregroundColor: UIColor.primary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: "READ MORE", attributes: attrs), for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private lazy var addToBagButton: UIButton = {
        let button = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .kern: CGFloat(2.6),
            .font: UIFont.sans(size: 13, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        button.setAttributedTitle(NSAttributedString(string: "ADD TO BAG", attributes: attrs), for: .normal)
        button.layer.cornerRadius = 0
        button.backgroundColor = .primary
        return button
    }()

    private lazy var wishlistShareStack: UIStackView = {
        let heartIcon = UIImageView(image: UIImage(systemName: "heart"))
        heartIcon.tintColor = .primaryDim
        heartIcon.contentMode = .scaleAspectFit
        heartIcon.translatesAutoresizingMaskIntoConstraints = false

        let shareIcon = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
        shareIcon.tintColor = .primaryDim
        shareIcon.contentMode = .scaleAspectFit
        shareIcon.translatesAutoresizingMaskIntoConstraints = false

        let divider = UIView()
        divider.backgroundColor = .surfaceVariant
        divider.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heartIcon.widthAnchor.constraint(equalToConstant: 16),
            heartIcon.heightAnchor.constraint(equalToConstant: 16),
            shareIcon.widthAnchor.constraint(equalToConstant: 16),
            shareIcon.heightAnchor.constraint(equalToConstant: 16),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 16)
        ])

        let wishlistGroup = UIStackView(arrangedSubviews: [heartIcon, makeWishlistLabel("WISHLIST")])
        wishlistGroup.axis = .horizontal
        wishlistGroup.spacing = 6
        wishlistGroup.alignment = .center

        let shareGroup = UIStackView(arrangedSubviews: [shareIcon, makeWishlistLabel("SHARE")])
        shareGroup.axis = .horizontal
        shareGroup.spacing = 6
        shareGroup.alignment = .center

        let sv = UIStackView(arrangedSubviews: [wishlistGroup, divider, shareGroup])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        sv.distribution = .equalCentering
        return sv
    }()

    private lazy var sizeAccordion: AccordionSectionView = {
        let v = AccordionSectionView()
        v.setTitle("SIZE & FIT")
        return v
    }()

    private lazy var compositionAccordion: AccordionSectionView = {
        let v = AccordionSectionView()
        v.setTitle("COMPOSITION & CARE")
        return v
    }()

    private lazy var shippingAccordion: AccordionSectionView = {
        let v = AccordionSectionView()
        v.setTitle("SHIPPING & RETURNS")
        return v
    }()

    private lazy var editorsAccordion: AccordionSectionView = {
        let v = AccordionSectionView()
        v.setTitle("EDITOR'S ADVICE")
        return v
    }()

    private var optionGroupViews: [OptionGroupView] = []

    private var currentDetail: ProductDetail?
    private var cachedDetails: [String: ProductDetail] = [:]
    private var selectedValueIDs: [String: String] = [:]
    private let resolver = SelectionStateResolver()

    private var loadAdapter: LoadResourcePresentationAdapter<ProductDetail, ProductDetailViewController>!

    init(slug: String, repository: ProductDetailRepositoryProtocol, imageLoader: ImageLoader) {
        self.repository = repository
        self.requestedSlug = slug
        self.mediaCarouselView = MediaCarouselView()
        self.mediaCarouselViewAdapter = MediaCarouselViewAdapter(view: self.mediaCarouselView, imageLoader: imageLoader)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupContentStack()
        let linePageControl = mediaCarouselView.linePageControl
        linePageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(mediaCarouselView)
        scrollView.addSubview(linePageControl)
        scrollView.addSubview(contentStack)
        view.addSubview(loadingIndicator)
        view.addSubview(errorBanner)
        setupLayout()
        setupLoadAdapter(slug: requestedSlug)
        loadAdapter.loadResource()
    }

    private func setupContentStack() {
        [
            brandLabel,
            productNameLabel,
            priceAmberStack,
            productIDLabel,
            descriptionLabel,
            readMoreButton,
            optionsStack,
            addToBagButton,
            wishlistShareStack,
            sizeAccordion,
            compositionAccordion,
            shippingAccordion,
            editorsAccordion
        ].forEach(contentStack.addArrangedSubview)

        contentStack.setCustomSpacing(4, after: brandLabel)
        contentStack.setCustomSpacing(12, after: productNameLabel)
        contentStack.setCustomSpacing(8, after: priceAmberStack)
        contentStack.setCustomSpacing(20, after: productIDLabel)
        contentStack.setCustomSpacing(8, after: descriptionLabel)
        contentStack.setCustomSpacing(20, after: readMoreButton)
        contentStack.setCustomSpacing(16, after: addToBagButton)
        contentStack.setCustomSpacing(8, after: wishlistShareStack)
        contentStack.setCustomSpacing(0, after: sizeAccordion)
        contentStack.setCustomSpacing(0, after: compositionAccordion)
        contentStack.setCustomSpacing(0, after: shippingAccordion)
    }

    private func setupLayout() {
        let linePageControl = mediaCarouselView.linePageControl
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mediaCarouselView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mediaCarouselView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            mediaCarouselView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            mediaCarouselView.heightAnchor.constraint(equalTo: mediaCarouselView.widthAnchor, multiplier: 1.33),

            linePageControl.topAnchor.constraint(equalTo: mediaCarouselView.bottomAnchor, constant: 4),
            linePageControl.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            linePageControl.heightAnchor.constraint(equalToConstant: 2),

            contentStack.topAnchor.constraint(equalTo: linePageControl.bottomAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),

            addToBagButton.heightAnchor.constraint(equalToConstant: 56),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func makeWishlistLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text, attributes: [
            .kern: CGFloat(1.5),
            .font: UIFont.sans(size: 10, weight: .medium),
            .foregroundColor: UIColor.primaryDim
        ])
        return label
    }

    private func setupLoadAdapter(slug: String) {
        loadAdapter = LoadResourcePresentationAdapter(
            loader: { [weak self] in
                guard let self else { throw CancellationError() }
                return try await self.repository.fetchDetail(slug: slug)
            }
        )
        let presenter = LoadResourcePresenter<ProductDetail, ProductDetailViewController>(
            resourceView: self,
            loadingView: self,
            errorView: self
        )
        loadAdapter.presenter = presenter
    }

    private func applyDisplay(_ model: ProductDetailDisplayModel) {
        brandLabel.attributedText = NSAttributedString(string: model.designerName.uppercased(), attributes: [
            .kern: CGFloat(3.3),
            .font: UIFont.serif(size: 11, weight: .light),
            .foregroundColor: UIColor.primary
        ])
        productNameLabel.text = model.productName
        priceLabel.text = model.priceText
        amberPointsLabel.text = model.amberPointsText
        priceAmberStack.arrangedSubviews.dropFirst().forEach { $0.isHidden = model.amberPointsText == nil }
        productIDLabel.attributedText = NSAttributedString(string: model.productIDText, attributes: [
            .kern: CGFloat(1.2),
            .font: UIFont.sans(size: 11, weight: .medium),
            .foregroundColor: UIColor.primaryDim
        ])
        descriptionLabel.text = model.descriptionText
        readMoreButton.isHidden = (model.descriptionText?.isEmpty ?? true)
        mediaCarouselViewAdapter.display(model.media)
        renderOptionGroups(model.optionGroups)
        addToBagButton.isEnabled = model.isAddToBagEnabled
        addToBagButton.alpha = model.isAddToBagEnabled ? 1 : 0.45
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
                self?.handleOptionSelection(groupID: group.id, valueID: valueID)
            }
            optionsStack.addArrangedSubview(groupView)
            optionGroupViews.append(groupView)
        }
    }

    private func handleOptionSelection(groupID: String, valueID: String) {
        guard let detail = currentDetail else { return }

        if
            let remoteSlug = detail.remoteSelectionSlugsByGroupID[groupID]?[valueID],
            selectedValueIDs[groupID] != valueID
        {
            if let cached = cachedDetails[valueID] {
                let previousSizeID = selectedValueIDs[ProductOptionGroupID.size]
                currentDetail = cached
                requestedSlug = cached.slug
                selectedValueIDs = cached.initialSelectedValues
                if
                    let previousSizeID,
                    let sizeGroup = cached.optionGroups.first(where: { $0.id == ProductOptionGroupID.size }),
                    sizeGroup.values.contains(where: { $0.id == previousSizeID && $0.isAvailable })
                {
                    selectedValueIDs[ProductOptionGroupID.size] = previousSizeID
                }
                refreshDisplay()
                return
            }

            let previousSizeID = selectedValueIDs[ProductOptionGroupID.size]
            requestedSlug = remoteSlug
            setupLoadAdapter(slug: remoteSlug)
            if let previousSizeID { preservedSizeID = previousSizeID }
            loadAdapter.loadResource()
            return
        }

        selectedValueIDs[groupID] = valueID
        refreshDisplay()
    }

    private var preservedSizeID: String?

    private func refreshDisplay() {
        guard let detail = currentDetail else { return }
        let state = resolver.resolve(
            optionGroups: detail.optionGroups,
            variants: detail.variants,
            selectedValueIDs: selectedValueIDs,
            fallbackVariantID: detail.fallbackVariantID,
            externallySelectableValueIDsByGroupID: detail.remoteSelectionSlugsByGroupID.mapValues { Set($0.keys) }
        )
        let model = ProductDetailPresenter.map(detail, selectionState: state)
        applyDisplay(model)
    }
}

extension ProductDetailViewController: ResourceView {
    typealias ResourceViewModel = ProductDetail

    func display(_ detail: ProductDetail) {
        cachedDetails[detail.styleColorID] = detail
        currentDetail = detail
        requestedSlug = detail.slug

        var values = detail.initialSelectedValues
        if
            let preserved = preservedSizeID,
            let sizeGroup = detail.optionGroups.first(where: { $0.id == ProductOptionGroupID.size }),
            sizeGroup.values.contains(where: { $0.id == preserved && $0.isAvailable })
        {
            values[ProductOptionGroupID.size] = preserved
        }
        preservedSizeID = nil
        selectedValueIDs = values

        scrollView.isHidden = false
        errorBanner.message = nil
        refreshDisplay()
    }
}

extension ProductDetailViewController: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}

extension ProductDetailViewController: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        if let message = viewModel.message, currentDetail == nil {
            scrollView.isHidden = true
            errorBanner.message = "Couldn't load product: \(message)"
        } else {
            errorBanner.message = viewModel.message
        }
    }
}
