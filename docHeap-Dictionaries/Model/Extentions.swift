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
}

extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "\(self) could not find in Licalizable.settings")
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


