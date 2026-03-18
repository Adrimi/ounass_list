import UIKit

final class ErrorView: UIView {
    var onHide: (() -> Void)?

    private lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(hideMessage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var message: String? {
        get { messageButton.title(for: .normal) }
        set { setMessageAnimated(newValue) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.92, green: 0.22, blue: 0.22, alpha: 1)
        addSubview(messageButton)
        NSLayoutConstraint.activate([
            messageButton.topAnchor.constraint(equalTo: topAnchor),
            messageButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        isHidden = true
        alpha = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func hideMessage() {
        message = nil
        onHide?()
    }

    private func setMessageAnimated(_ message: String?) {
        messageButton.setTitle(message, for: .normal)
        UIView.animate(withDuration: 0.25) {
            self.isHidden = message == nil
            self.alpha = message == nil ? 0 : 1
        }
    }
}
