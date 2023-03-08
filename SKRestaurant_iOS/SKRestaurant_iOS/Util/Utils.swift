//
//  Utils.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/08.
//

import Foundation

func log(_ item: Any, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
    print(file + ":\(line):" + function, item)
}

extension Date {
    var milliTimeIntervalSince1970:Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}


let USER_DEFAULTS_USER_TOKEN = "USER_DEFAULTS_USER_TOKEN"

extension UserDefaults {
    static var sk_default:UserDefaults {
        return UserDefaults(suiteName: "sk_restaurant")!
    }
}
