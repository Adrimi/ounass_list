import UIKit

final class OptionGroupView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(white: 0.14, alpha: 1)
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(group: ResolvedOptionGroup, onSelection: @escaping (String) -> Void) {
        titleLabel.text = group.title

        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        group.values.forEach { value in
            let button = OptionValueButton(style: group.displayStyle)
            button.apply(resolvedValue: value)
            button.onTap = { onSelection(value.value.id) }
            stackView.addArrangedSubview(button)
        }
    }
}
