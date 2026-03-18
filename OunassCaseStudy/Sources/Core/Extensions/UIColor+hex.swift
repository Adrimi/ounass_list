import UIKit

extension UIColor {
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
