//
//  String + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation
import UIKit

public extension String {
    func isNumeric() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func isEmailAddress() -> Bool {
        // Regular expression to validate email addresses
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func htmlToAttributedString() -> NSAttributedString? {
        guard let data = data(using: .unicode) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]
        
        do {
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return attributedString
        } catch {
            print("Error converting HTML to attributed string: \(error)")
            return nil
        }
    }
    
    func toAttributedStringFromHTML(fontSize: CGFloat, fontColor: UIColor, fontName: String) -> NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            // Create a mutable attributed string to modify the font size, color, and name
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            
            // Enumerate through the ranges of the attributed string
            mutableAttributedString.enumerateAttributes(in: NSRange(location: 0, length: mutableAttributedString.length), options: []) { (attributes, range, _) in
                // Modify the font size
                if let currentFont = attributes[.font] as? UIFont {
                    let resizedFont = currentFont.withSize(fontSize)
                    mutableAttributedString.addAttribute(.font, value: resizedFont, range: range)
                }
                
                // Modify the font color
                mutableAttributedString.addAttribute(.foregroundColor, value: fontColor, range: range)
                
                // Modify the font name
                if let currentFont = attributes[.font] as? UIFont {
                    let modifiedFontDescriptor = currentFont.fontDescriptor.withFamily(fontName)
                    let modifiedFont = UIFont(descriptor: modifiedFontDescriptor, size: fontSize)
                    mutableAttributedString.addAttribute(.font, value: modifiedFont, range: range)
                    
                }
            }
            
            return mutableAttributedString
        }
        
        return nil
    }
}
