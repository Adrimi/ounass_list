import UIKit

final class AccordionSectionView: UIView {
    private let titleLabel = UILabel()
    
    private lazy var iconView = {
        let imageView = UIImageView(image: UIImage(systemName: "plus"))
        imageView.tintColor = .primaryDim
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let contentContainer = UIView()
    private var isExpanded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.attributedText = NSAttributedString(string: title.uppercased(), attributes: [
            .kern: CGFloat(1.5),
            .font: UIFont.sans(size: 10, weight: .medium),
            .foregroundColor: UIColor.onSurface
        ])
    }

    func setContent(_ view: UIView) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }

    private func setup() {
        let borderView = UIView()
        borderView.backgroundColor = .surfaceContainer

        let headerRow = UIView()
        headerRow.isUserInteractionEnabled = true

        [titleLabel, iconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerRow.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerRow.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconView.leadingAnchor, constant: -8),
            iconView.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: headerRow.trailingAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16)
        ])

        contentContainer.isHidden = true

        let stack = UIStackView(arrangedSubviews: [borderView, headerRow, contentContainer])
        stack.axis = .vertical
        stack.setCustomSpacing(0, after: borderView)
        stack.setCustomSpacing(0, after: headerRow)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            borderView.heightAnchor.constraint(equalToConstant: 1),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        headerRow.addGestureRecognizer(tap)
    }

    @objc private func toggle() {
        isExpanded.toggle()
        UIView.animate(withDuration: 0.25) {
            self.contentContainer.isHidden = !self.isExpanded
            self.iconView.transform = self.isExpanded
                ? CGAffineTransform(rotationAngle: .pi / 4)
                : .identity
        }
    }
}
