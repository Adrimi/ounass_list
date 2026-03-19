import UIKit

final class ProductDetailViewController: UIViewController {
    private let slug: String
    private let repository: ProductDetailRepositoryProtocol
    private let imageLoader: ImageLoader

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 24
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var infoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
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
            let currentSlug = self.currentDetail?.slug ?? self.slug
            self.setupLoadAdapter(slug: currentSlug)
            self.loadAdapter.loadResource()
        }
        return view
    }()

    private let mediaCarouselView: MediaCarouselView

    private lazy var designerLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 11, weight: .semibold)
        label.textColor = .primaryDim
        label.numberOfLines = 0
        return label
    }()

    private lazy var productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .serif(size: 28, weight: .light)
        label.textColor = .onSurface
        label.numberOfLines = 0
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 20, weight: .medium)
        label.textColor = .secondary
        return label
    }()

    private lazy var amberPointsLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 14, weight: .medium)
        label.textColor = .secondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var productCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 13)
        label.textColor = .primaryDim
        return label
    }()

    private lazy var addToBagButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Add to Bag", for: .normal)
        button.titleLabel?.font = .sans(size: 17, weight: .semibold)
        button.layer.cornerRadius = 0
        return button
    }()

    private lazy var addToBagGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.primary.cgColor, UIColor.primaryDim.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient
    }()

    private lazy var descriptionHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .serif(size: 16)
        label.textColor = .onSurface
        label.text = "Editor's advice"
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 15)
        label.textColor = .primary
        label.numberOfLines = 0
        return label
    }()

    private var optionGroupViews: [OptionGroupView] = []

    private var currentDetail: ProductDetail?
    private var cachedDetails: [String: ProductDetail] = [:]
    private var selectedValueIDs: [String: String] = [:]
    private let resolver = SelectionStateResolver()

    private var loadAdapter: LoadResourcePresentationAdapter<ProductDetail, ProductDetailViewController>!

    init(slug: String, repository: ProductDetailRepositoryProtocol, imageLoader: ImageLoader) {
        self.slug = slug
        self.repository = repository
        self.imageLoader = imageLoader
        self.mediaCarouselView = MediaCarouselView(imageLoader: imageLoader)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        addToBagButton.layer.insertSublayer(addToBagGradient, at: 0)
        [designerLabel, productNameLabel, priceLabel, amberPointsLabel, productCodeLabel].forEach(infoStack.addArrangedSubview)
        [mediaCarouselView, infoStack, optionsStack, addToBagButton, descriptionHeaderLabel, descriptionLabel].forEach(contentStack.addArrangedSubview)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(loadingIndicator)
        view.addSubview(errorBanner)
        setupLayout()
        setupLoadAdapter(slug: slug)
        loadAdapter.loadResource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addToBagGradient.frame = addToBagButton.bounds
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
            errorBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
        title = model.title
        designerLabel.attributedText = NSAttributedString(string: model.designerName.uppercased(), attributes: [
            .kern: 0.8,
            .font: UIFont.sans(size: 11, weight: .semibold),
            .foregroundColor: UIColor.primaryDim
        ])
        productNameLabel.text = model.productName
        priceLabel.text = model.priceText
        amberPointsLabel.text = model.amberPointsText
        amberPointsLabel.isHidden = model.amberPointsText == nil
        productCodeLabel.text = model.productCodeText
        descriptionLabel.text = model.descriptionText
        descriptionHeaderLabel.isHidden = model.descriptionText?.isEmpty ?? true
        descriptionLabel.isHidden = model.descriptionText?.isEmpty ?? true
        mediaCarouselView.render(media: model.media)
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
            fallbackVariantID: detail.fallbackVariantID
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
