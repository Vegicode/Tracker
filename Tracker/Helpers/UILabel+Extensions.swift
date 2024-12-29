

import UIKit

extension UILabel {
    func configureLabel(font: UIFont, textColor: UIColor, aligment: NSTextAlignment?) {
        self.font = font
        self.textColor = textColor
        if let aligment = aligment {
            self.textAlignment = aligment
        }
    }
}
