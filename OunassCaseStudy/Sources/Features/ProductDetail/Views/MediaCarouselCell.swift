import UIKit

final class MediaCarouselCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaCarouselCell"

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.backgroundColor = UIColor(white: 0.92, alpha: 1)
        return iv
    }()

    private var imageLoadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
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
