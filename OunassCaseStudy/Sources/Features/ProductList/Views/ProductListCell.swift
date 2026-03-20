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

    private(set) lazy var imageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .surfaceContainer
        view.clipsToBounds = true
        return view
    }()

    private(set) lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private(set) lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        button.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: configuration), for: .normal)
        button.tintColor = .primary
        button.backgroundColor = UIColor.appBackground.withAlphaComponent(0.92)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
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

    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(stackView)
        [imageContainer, designerLabel, nameLabel, priceLabel].forEach(stackView.addArrangedSubview)
        imageContainer.addSubview(imageView)
        imageContainer.addSubview(retryButton)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 1.45),
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            retryButton.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 36),
            retryButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onRetry = nil
        imageView.image = nil
        imageContainer.isShimmering = false
        retryButton.isHidden = true
    }

    func configure(with product: ProductSummary) {
        designerLabel.attributedText = trackedString(product.designerName.uppercased(), kern: 0.8)
        nameLabel.text = product.name
        priceLabel.text = product.price.formatted
        imageView.image = nil
        imageContainer.isShimmering = false
        retryButton.isHidden = true
    }

    private func trackedString(_ string: String, kern: CGFloat) -> NSAttributedString {
        NSAttributedString(string: string, attributes: [
            .kern: kern,
            .font: UIFont.sans(size: 10, weight: .semibold),
            .foregroundColor: UIColor.primaryDim
        ])
    }

    @objc
    private func retryButtonTapped() {
        onRetry?()
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    let cell = ProductListCell(frame: .zero)
    cell.configure(with: .fake())
    return cell
}
#endif
