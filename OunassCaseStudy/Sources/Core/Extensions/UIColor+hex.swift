import UIKit

extension UIColor {
    static let appBackground = UIColor(hex: "#fcf9f8")!
    static let primary = UIColor(hex: "#5f5e5e")!
    static let primaryDim = UIColor(hex: "#535252")!
    static let secondary = UIColor(hex: "#785a1a")!
    static let onSurface = UIColor(hex: "#323233")!
    static let surfaceContainer = UIColor(hex: "#f0eded")!
    static let surfaceVariant = UIColor(hex: "#e4e2e2")!

    convenience init?(hex: String?) {
        guard
            let hex,
            hex.hasPrefix("#")
        else {
            return nil
        }

        let hexString = String(hex.dropFirst())
        guard let intValue = Int(hexString, radix: 16) else {
            return nil
        }

        let red = CGFloat((intValue >> 16) & 0xFF) / 255
        let green = CGFloat((intValue >> 8) & 0xFF) / 255
        let blue = CGFloat(intValue & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
