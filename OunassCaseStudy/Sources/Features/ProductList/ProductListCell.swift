import UIKit

final class ProductListCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductListCell"

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 6
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .surfaceContainer
        return iv
    }()

    private lazy var designerLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 10, weight: .semibold)
        label.textColor = .primaryDim
        label.numberOfLines = 1
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .serif(size: 14)
        label.textColor = .onSurface
        label.numberOfLines = 3
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 13, weight: .medium)
        label.textColor = .secondary
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
        designerLabel.attributedText = trackedString(product.designerName.uppercased(), kern: 0.8)
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

    private func trackedString(_ string: String, kern: CGFloat) -> NSAttributedString {
        NSAttributedString(string: string, attributes: [
            .kern: kern,
            .font: UIFont.sans(size: 10, weight: .semibold),
            .foregroundColor: UIColor.primaryDim
        ])
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    let cell = ProductListCell(frame: .zero)
    cell.configure(with: .fake(), imageLoader: FakeImageLoader())
    return cell
}
#endif
