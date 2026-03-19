import UIKit

final class OptionGroupView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .sans(size: 12, weight: .medium)
        label.textColor = .primary
        return label
    }()

    private var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(group: ResolvedOptionGroup, onSelection: @escaping (String) -> Void) {
        titleLabel.text = group.title

        contentView?.removeFromSuperview()
        contentView = nil

        let newContent: UIView
        if group.displayStyle == .swatch {
            newContent = buildSwatchContent(group: group, onSelection: onSelection)
        } else {
            newContent = buildTextGridContent(group: group, onSelection: onSelection)
        }

        newContent.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newContent)
        NSLayoutConstraint.activate([
            newContent.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            newContent.leadingAnchor.constraint(equalTo: leadingAnchor),
            newContent.trailingAnchor.constraint(equalTo: trailingAnchor),
            newContent.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        contentView = newContent
    }

    private func buildSwatchContent(group: ResolvedOptionGroup, onSelection: @escaping (String) -> Void) -> UIView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 40),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        group.values.forEach { value in
            let button = OptionValueButton(style: .swatch)
            button.apply(resolvedValue: value)
            button.onTap = { onSelection(value.value.id) }
            stack.addArrangedSubview(button)
        }

        return scrollView
    }

    private func buildTextGridContent(group: ResolvedOptionGroup, onSelection: @escaping (String) -> Void) -> UIView {
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = 8

        let chunks = stride(from: 0, to: group.values.count, by: 4).map {
            Array(group.values[$0..<min($0 + 4, group.values.count)])
        }

        for chunk in chunks {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually

            for value in chunk {
                let button = OptionValueButton(style: .text)
                button.apply(resolvedValue: value)
                button.onTap = { onSelection(value.value.id) }
                rowStack.addArrangedSubview(button)
            }

            let remaining = 4 - chunk.count
            for _ in 0..<remaining {
                rowStack.addArrangedSubview(UIView())
            }

            outerStack.addArrangedSubview(rowStack)
        }

        return outerStack
    }
}
