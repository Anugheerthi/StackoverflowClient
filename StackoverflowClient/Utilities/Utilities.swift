//
//  Utilities.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 16/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import Foundation
import UIKit

var access_token: String {
    get {
        return UserDefaults.standard.string(forKey: kUD_Auth) ?? ""
    }
}

var isAuthenticatedUser: Bool {
    return false
}

func setAccessTokenUserDefault(_ authToken: String) {
    UserDefaults.standard.set(authToken, forKey: kUD_Auth)
}

extension UIViewController {
    
    func presentAlert(_ title: String = "", _ message: String = "", _ completion: (() -> ())? = nil) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let alertOkButton = UIAlertAction.init(title: "OK", style: .cancel) { (_) in
            completion?()
        }
        alertVC.addAction(alertOkButton)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

extension URL {
    
    func extractAccessToken() -> String {
        let urlComponent = URLComponents(url: self, resolvingAgainstBaseURL: true)
        guard let access_token = urlComponent?.fragment else {
            return ""
        }
        return access_token.replacingOccurrences(of: "access_token=", with: "")
    }
    
}

extension Date {
    
    // Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    // Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    // Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    static func getTimeStampText(_ fromDate: Date) -> String {
        let minute = Date().minutes(from: fromDate)
        let hour = Date().hours(from: fromDate)
        let days = Date().days(from: fromDate)
        
        var timeStamp = ""
        if hour < 1 {
            timeStamp = "\(minute)m ago"
        } else if hour >= 1 && hour <= 6 {
            timeStamp = "\(hour)h ago"
        } else if hour > 6 && days <= 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE h:mm a" // Fri 12:43 PM
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            timeStamp = formatter.string(from: fromDate)
        } else if days > 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy" //Nov 17, 2019
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            timeStamp = formatter.string(from: fromDate)
        }
        
        return timeStamp
    }
    
}

// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities : [ Substring : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",

    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]

extension String {
    
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities : String {

        // ===== Utility functions =====

        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }

        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : Substring) -> Character? {

            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return characterEntities[entity]
            }
        }

        // ===== Method starts here =====

        var result = ""
        var position = startIndex

        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound

            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound

            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])
        return result
    }
    
}

extension UIView {
    
    func addAsSubViewWithEqualConstraintTo(_ containerView: UIView, _ edgeInset: UIEdgeInsets = .zero) {
        self.frame = containerView.bounds
        containerView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: edgeInset.top),
            self.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: edgeInset.left),
            self.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: edgeInset.right),
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: edgeInset.bottom),
            ])
    }
    
}
