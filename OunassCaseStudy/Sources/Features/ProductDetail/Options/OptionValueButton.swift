import UIKit

final class OptionValueButton: UIControl {
    var onTap: (() -> Void)?

    private let style: ProductOptionDisplayStyle

    private lazy var swatchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.surfaceVariant.cgColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .sans(size: 13, weight: .medium)
        label.textColor = .primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var strikethroughLayer: CALayer?

    init(style: ProductOptionDisplayStyle) {
        self.style = style
        super.init(frame: .zero)
        layer.cornerRadius = 0

        if style == .swatch {
            setupSwatchLayout()
        } else {
            setupTextLayout()
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateStrikethrough()
    }

    func apply(resolvedValue: ResolvedOptionValue) {
        isEnabled = resolvedValue.isEnabled

        if style == .swatch {
            swatchView.backgroundColor = UIColor(hex: resolvedValue.value.swatchHex) ?? UIColor(white: 0.95, alpha: 1)
            layer.borderWidth = resolvedValue.isSelected ? 1 : 0
            layer.borderColor = UIColor.primary.cgColor
            alpha = resolvedValue.isEnabled ? 1 : 0.35
        } else {
            titleLabel.text = resolvedValue.value.title
            if resolvedValue.isSelected {
                backgroundColor = .primary
                layer.borderWidth = 0
                titleLabel.textColor = .white
            } else {
                backgroundColor = .surfaceContainer
                layer.borderWidth = 1
                layer.borderColor = UIColor.surfaceVariant.cgColor
                titleLabel.textColor = .primary
            }
            alpha = resolvedValue.isEnabled ? 1 : 0.35
            setNeedsLayout()
        }
    }

    @objc private func handleTap() {
        guard isEnabled else { return }
        onTap?()
    }

    private func setupSwatchLayout() {
        backgroundColor = .appBackground
        addSubview(swatchView)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 40),
            heightAnchor.constraint(equalToConstant: 40),
            swatchView.widthAnchor.constraint(equalToConstant: 32),
            swatchView.heightAnchor.constraint(equalToConstant: 32),
            swatchView.centerXAnchor.constraint(equalTo: centerXAnchor),
            swatchView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupTextLayout() {
        backgroundColor = .surfaceContainer
        layer.borderWidth = 1
        layer.borderColor = UIColor.surfaceVariant.cgColor
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
        ])
    }

    private func updateStrikethrough() {
        strikethroughLayer?.removeFromSuperlayer()
        strikethroughLayer = nil

        guard style == .text, !isEnabled, bounds.width > 0 else { return }

        let diag = sqrt(pow(bounds.width, 2) + pow(bounds.height, 2))
        let sl = CALayer()
        sl.backgroundColor = UIColor.surfaceVariant.cgColor
        sl.frame = CGRect(
            x: (bounds.width - diag) / 2,
            y: (bounds.height - 1) / 2,
            width: diag,
            height: 1
        )
        let angle = atan2(bounds.height, bounds.width)
        sl.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        layer.addSublayer(sl)
        strikethroughLayer = sl
    }
}
