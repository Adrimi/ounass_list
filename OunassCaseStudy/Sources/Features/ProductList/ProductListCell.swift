import UIKit

final class ProductListCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductListCell"

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(white: 0.93, alpha: 1)
        iv.layer.cornerRadius = 18
        return iv
    }()

    private lazy var designerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor(white: 0.35, alpha: 1)
        label.numberOfLines = 2
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(white: 0.16, alpha: 1)
        label.numberOfLines = 3
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(white: 0.1, alpha: 1)
        return label
    }()

    private var imageLoadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(stackView)
        [imageView, designerLabel, nameLabel, priceLabel].forEach(stackView.addArrangedSubview)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.45)
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

    func configure(with product: ProductSummary, imageLoader: ImageLoader) {
        designerLabel.text = product.designerName.uppercased()
        nameLabel.text = product.name
        priceLabel.text = product.price.formatted
        imageView.image = nil

        imageLoadTask?.cancel()

        guard let url = product.thumbnailURL else {
            return
        }

        imageLoadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            if let image = try? await imageLoader.loadImage(from: url) {
                self.imageView.image = image
            }
        }
    }
}
