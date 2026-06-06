//
//  String+UIKit.swift
//
//  UIKit-dependent String helpers. Moved out of DevToolsCore so that Core
//  remains framework-agnostic (Foundation only).
//

import UIKit

public extension String {

    /// Converts an HTML string to an `NSAttributedString` using the HTML document type.
    func htmlToAttributedString() -> NSAttributedString? {
        guard let data = data(using: .unicode) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }

    /// Converts an HTML string to an `NSAttributedString`, applying the given
    /// font size, colour, and font family to all runs of text.
    func toAttributedStringFromHTML(
        fontSize: CGFloat,
        fontColor: UIColor,
        fontName: String
    ) -> NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(
            data: data, options: options, documentAttributes: nil
        ) else { return nil }

        let mutable = NSMutableAttributedString(attributedString: attributedString)
        let fullRange = NSRange(location: 0, length: mutable.length)

        mutable.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            if let font = attributes[.font] as? UIFont {
                let descriptor = font.fontDescriptor.withFamily(fontName)
                mutable.addAttribute(.font,
                                     value: UIFont(descriptor: descriptor, size: fontSize),
                                     range: range)
            }
            mutable.addAttribute(.foregroundColor, value: fontColor, range: range)
        }

        return mutable
    }
}
