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
        return Calendar.current.dateComponents([.day], from: date, to: self).hour ?? 0
    }
    
    static func getTimeStampText(_ fromDate: Date) -> String {
        let minute = Date().minutes(from: fromDate)
        let hour = Date().hours(from: fromDate)
        let days = Date().days(from: fromDate)
        
        debugPrint("min - \(minute), hr - \(hour)")
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