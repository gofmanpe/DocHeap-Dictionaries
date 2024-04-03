//
//  Extentions.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 19.11.23.
//

import Foundation
import UIKit

extension UIView {
    func traverseSubviews(_ action: () -> Void) {
        for subview in subviews {
            subview.traverseSubviews(action)
        }
        action()
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "\(self) could not find in Licalizable.settings")
    }
    func localizedPlural(_ arg:Int) -> String{
        let formatString = NSLocalizedString(self, comment: "\(self) could not find in Licalizable.stringsDict")
        return Self.localizedStringWithFormat(formatString, arg)
    }
    func transliterate() -> String {
        let latinString = self.applyingTransform(StringTransform.toLatin, reverse: false) ?? self
        return latinString
    }
    func replaceSpacesWithUnderscores() -> String {
        return self.replacingOccurrences(of: " ", with: "_")
    }
    func removeSpacesAndSpecialChars() -> String {
        let allowedCharacters = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        return self.filter { allowedCharacters.contains($0) }
    }
}

