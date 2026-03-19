import UIKit

final class ProductListHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .serif(size: 32, weight: .light)
        label.textColor = .onSurface
        label.text = "New Arrivals"
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: "READY-TO-WEAR • AUTUMN/WINTER 24",
            attributes: [
                .font: UIFont.sans(size: 10),
                .kern: CGFloat(2.0),
                .foregroundColor: UIColor.primaryDim
            ]
        )
        return label
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.sans(size: 12, weight: .medium),
            .foregroundColor: UIColor.primary
        ]
        button.setAttributedTitle(NSAttributedString(string: "FILTER", attributes: attrs), for: .normal)
        return button
    }()

    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.sans(size: 12, weight: .medium),
            .foregroundColor: UIColor.primary
        ]
        button.setAttributedTitle(NSAttributedString(string: "SORT", attributes: attrs), for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .appBackground

        let filterSortRow = UIStackView(arrangedSubviews: [filterButton, UIView(), sortButton])
        filterSortRow.axis = .horizontal
        filterSortRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, filterSortRow])
        stack.axis = .vertical
        stack.spacing = 6
        stack.setCustomSpacing(12, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
