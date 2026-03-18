import UIKit

final class ProductListCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductListCell"

    private let imageView = UIImageView()
    private let designerLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let stackView = UIStackView()
    private var imageLoadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildViewHierarchy()
        configureStyling()
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

    private func buildViewHierarchy() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        designerLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(designerLabel)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.45)
        ])
    }

    private func configureStyling() {
        contentView.backgroundColor = .clear

        imageView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        imageView.layer.cornerRadius = 18

        designerLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        designerLabel.textColor = UIColor(white: 0.35, alpha: 1)
        designerLabel.numberOfLines = 2

        nameLabel.font = .systemFont(ofSize: 15, weight: .regular)
        nameLabel.textColor = UIColor(white: 0.16, alpha: 1)
        nameLabel.numberOfLines = 3

        priceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        priceLabel.textColor = UIColor(white: 0.1, alpha: 1)
    }
}
