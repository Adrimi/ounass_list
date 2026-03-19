import UIKit

final class LinePageControl: UIView {
    var numberOfPages: Int = 0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    var currentPage: Int = 0 {
        didSet { setNeedsLayout() }
    }

    private var lineViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        guard numberOfPages > 0 else { return .zero }
        let width = 48 + CGFloat(numberOfPages - 1) * 36
        return CGSize(width: width, height: 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ensureLines()
        layoutLines()
    }

    private func ensureLines() {
        while lineViews.count < numberOfPages {
            let v = UIView()
            addSubview(v)
            lineViews.append(v)
        }
        while lineViews.count > numberOfPages {
            lineViews.removeLast().removeFromSuperview()
        }
    }

    private func layoutLines() {
        var x: CGFloat = 0
        for (i, line) in lineViews.enumerated() {
            let width: CGFloat = i == currentPage ? 48 : 32
            line.frame = CGRect(x: x, y: 0, width: width, height: 2)
            line.backgroundColor = i == currentPage ? .primary : .surfaceVariant
            x += width + 4
        }
    }
}
