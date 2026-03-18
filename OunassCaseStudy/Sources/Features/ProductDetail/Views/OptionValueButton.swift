import UIKit

final class OptionValueButton: UIControl {
    var onTap: (() -> Void)?

    private let style: ProductOptionDisplayStyle

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var swatchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 0.14, alpha: 1)
        return label
    }()

    init(style: ProductOptionDisplayStyle) {
        self.style = style
        super.init(frame: .zero)

        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
        backgroundColor = .white

        addSubview(stackView)
        stackView.addArrangedSubview(swatchView)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            swatchView.widthAnchor.constraint(equalToConstant: 20),
            swatchView.heightAnchor.constraint(equalToConstant: 20)
        ])

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(resolvedValue: ResolvedOptionValue) {
        titleLabel.text = resolvedValue.value.title
        swatchView.isHidden = style != .swatch

        if style == .swatch {
            swatchView.backgroundColor = UIColor(hex: resolvedValue.value.swatchHex) ?? UIColor(white: 0.95, alpha: 1)
        }

        isEnabled = resolvedValue.isEnabled
        alpha = resolvedValue.isEnabled ? 1 : 0.35

        if resolvedValue.isSelected {
            layer.borderColor = UIColor(white: 0.1, alpha: 1).cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
            layer.borderWidth = 1
        }
    }

    @objc private func handleTap() {
        guard isEnabled else { return }
        onTap?()
    }
}
