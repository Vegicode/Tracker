//
//  PaddedTextField.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import UIKit

final class PaddedTextField: UITextField {
    private lazy var textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonSize = super.clearButtonRect(forBounds: bounds).size
        
        let clearButtonX = bounds.width - clearButtonSize.width - 12
        return CGRect(
            x: clearButtonX,
            y: (bounds.height - clearButtonSize.height) / 2,
            width: clearButtonSize.width,
            height: clearButtonSize.height
        )
    }
}
