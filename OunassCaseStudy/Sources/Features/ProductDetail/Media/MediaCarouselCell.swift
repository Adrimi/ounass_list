import UIKit

final class MediaCarouselCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaCarouselCell"

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
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 0
        return iv
    }()

    private(set) lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: configuration), for: .normal)
        button.tintColor = .primary
        button.backgroundColor = UIColor.appBackground.withAlphaComponent(0.92)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageContainer)
        imageContainer.addSubview(imageView)
        imageContainer.addSubview(retryButton)
        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            retryButton.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 40),
            retryButton.heightAnchor.constraint(equalToConstant: 40)
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

    func prepareForDisplay() {
        imageView.image = nil
        imageContainer.isShimmering = false
        retryButton.isHidden = true
    }

    @objc
    private func retryButtonTapped() {
        onRetry?()
    }
}
