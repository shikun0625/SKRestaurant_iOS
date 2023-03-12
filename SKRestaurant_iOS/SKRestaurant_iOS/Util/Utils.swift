//
//  Utils.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/08.
//

import Foundation
import UIKit

func log(_ item: Any, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
    print(file + ":\(line):" + function, item)
}

extension Date {
    var milliTimeIntervalSince1970:Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}


let USER_DEFAULTS_USER_TOKEN = "USER_DEFAULTS_USER_TOKEN"
let USER_DEFAULTS_USER_NAME = "USER_DEFAULTS_USER_NAME"
let USER_DEFAULTS_PASSWORD = "USER_DEFAULTS_PASSWORD"
let USER_DEFAULTS_AUTH_EXPIRED_DATETIME = "USER_DEFAULTS_AUTH_EXPIRED_DATETIME"

extension UserDefaults {
    static var sk_default:UserDefaults {
        return UserDefaults(suiteName: "sk_restaurant")!
    }
    
    func setToken(token:String) -> Void {
        set(token, forKey: USER_DEFAULTS_USER_TOKEN)
    }
    
    func deleteToken() -> Void {
        removeObject(forKey: USER_DEFAULTS_USER_TOKEN)
    }
    
    func getToken() -> String? {
        return string(forKey: USER_DEFAULTS_USER_TOKEN)
    }
    
    func setUsername(username:String) -> Void {
        set(username, forKey: USER_DEFAULTS_USER_NAME)
    }
    
    func deleteUsername() -> Void {
        removeObject(forKey: USER_DEFAULTS_USER_NAME)
    }
    
    func getUsername() -> String? {
        return string(forKey: USER_DEFAULTS_USER_NAME)
    }
    
    func setPassword(password:String) -> Void {
        set(password, forKey: USER_DEFAULTS_PASSWORD)
    }
    
    func deletePassword() -> Void {
        removeObject(forKey: USER_DEFAULTS_PASSWORD)
    }
    
    func getPassword() -> String? {
        return string(forKey: USER_DEFAULTS_PASSWORD)
    }
    
    func setExpiredDateTime(date:Date) -> Void {
        set(date, forKey: USER_DEFAULTS_AUTH_EXPIRED_DATETIME)
    }
    
    func deleteExpiredDateTime() -> Void {
        removeObject(forKey: USER_DEFAULTS_AUTH_EXPIRED_DATETIME)
    }
    
    func getExpiredDateTime() -> Date? {
        return object(forKey: USER_DEFAULTS_AUTH_EXPIRED_DATETIME) as? Date
    }
}

extension Notification {
    public static let SKShowMaterielViewNotification = Notification(name: .SKShowMaterielViewNotificationName)
    public static let SKMaterielViewRefreshNotification = Notification(name: .SKMaterielViewRefreshNotificationName)
}

extension Notification.Name {
    public static let SKShowMaterielViewNotificationName = Notification.Name("SKShowMaterielViewNotification")
    public static let SKMaterielViewRefreshNotificationName = Notification.Name("SKMaterielViewRefreshNotificationName")
}

@IBDesignable class DesignableButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
}
