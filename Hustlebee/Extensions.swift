//
//  Extensions.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/3/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var isBlank: Bool {
        get {
            let trimmmed = self.trimmingCharacters(in: NSCharacterSet.whitespaces)
            return trimmmed.isEmpty
        }
    }
    
    var isValidEmail: Bool {
        do {
            let pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    var isValidPassword: Bool {
        return self.characters.count >= 6 ? true : false
    }
}

extension UIButton {
    func changeBtnStateTo(enabled: Bool) {
        if enabled {
            self.isEnabled = true
            self.alpha = 1.0
        } else {
            self.isEnabled = false
            self.alpha = 0.3
        }
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    class func warningAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        return alert
    }
}

extension UIColor {
    class func yellowTheme() -> UIColor {
        return UIColor(red: 228/255, green: 187/255, blue: 22/255, alpha: 1.00)
    }
}


