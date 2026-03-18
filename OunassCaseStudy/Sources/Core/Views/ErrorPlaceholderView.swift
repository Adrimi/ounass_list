import UIKit

final class ErrorPlaceholderView: UIView {
    var onAction: (() -> Void)?

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        [titleLabel, messageLabel, actionButton].forEach(stackView.addArrangedSubview)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.14, alpha: 1)
        titleLabel.textAlignment = .center

        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = UIColor(white: 0.38, alpha: 1)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = UIColor(white: 0.12, alpha: 1)
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        actionButton.layer.cornerRadius = 12
        actionButton.addTarget(self, action: #selector(handleActionTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(title: String, message: String, actionTitle: String = "Try Again") {
        titleLabel.text = title
        messageLabel.text = message
        actionButton.setTitle(actionTitle, for: .normal)
    }

    @objc private func handleActionTap() {
        onAction?()
    }
}

extension UIColor {
    static let appBackground = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1)
}
