//
//  Utils.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/08.
//

import Foundation
import UIKit

func log(_ item: Any, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
    objc_sync_enter(item)
    print(file + ":\(line):" + function, item)
    objc_sync_exit(item)
}

func convertUnitToString(unit:Int) -> String {
    objc_sync_enter(unit)
    var result:String = "未知"
    switch unit {
    case 0:
        result = "份"
    case 1:
        result = "块"
    case 2:
        result = "瓶"
    case 3:
        result = "碗"
    case 4:
        result = "个"
    case 5:
        result = "包"
    case 6:
        result = "克"
    case 7:
        result = "斤"
    case 8:
        result = "箱"
    default:
        result = "未知"
    }
    objc_sync_exit(unit)
    return result
}

func convertMaterielTypeToString(type:Int) -> String {
    objc_sync_enter(type)
    var result:String = "未知"
    switch type {
    case 0:
        result = "可销售"
    case 1:
        result = "不可销售"
    default:
        break
    }
    objc_sync_exit(type)
    return result
}

func converMaterielActionReasonToString(actionType:Int, reason:Int) -> String {
    objc_sync_enter(actionType)
    var result:String = "未知"
    switch actionType {
    case 0:
        switch reason {
        case 0:
            result = "购入"
        case 1:
            result = "制作"
        case 2:
            result = "退货"
        default:
            break
        }
    case 1:
        switch reason {
        case 0:
            result = "制作"
        case 1:
            result = "销售"
        case 2:
            result = "报废"
        default:
            break
        }
    default:
        break
    }
    objc_sync_exit(actionType)
    return result
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
    public static let SKShowMealsViewNotification = Notification(name: .SKShowMealsViewNotification)
}

extension Notification.Name {
    public static let SKShowMaterielViewNotificationName = Notification.Name("SKShowMaterielViewNotification")
    public static let SKShowMealsViewNotification = Notification.Name("SKShowMealsViewNotification")
    
    public static let SKMaterielAddedNotificationName = Notification.Name("SKMaterielAddedNotificationName")
    public static let SKMaterielUpdatedNotificationName = Notification.Name("SKMaterielUpdatedNotificationName")
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
