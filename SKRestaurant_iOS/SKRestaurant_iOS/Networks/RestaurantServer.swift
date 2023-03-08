//
//  RestaurantServer.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/08.
//

import Foundation
import HandyJSON
import SwiftyJSON
import Alamofire
import CryptoSwift

let HTTP_SERVER_ADDRESS:String = {
    if TARGET_OS_SIMULATOR != 0 {
        return "http://127.0.0.1:8080/SKRestaurant_Server"
    } else {
        return "http://127.0.0.1:8080/SKRestaurant_Server"
    }
}()

enum SKHttpRequestResult {
    case success
    case failure
    case cancel
    case uploading
    case downloading
}

enum SKHTTPError: Error {
    case HTTP_PARAMETER
}


protocol HttpServiceDelegate:AnyObject {
    func requestCompleted(result:SKHttpRequestResult, output:Any?, error:Error?)
}

extension HttpServiceDelegate {
    func requestCompleted(result:SKHttpRequestResult, output:Any?, error:Error?) {
        log("未实现 requestCompleted")
    }
}

protocol HttpServiceParameter:Encodable {
    func check()->Bool
}

protocol HttpServiceProtocol {
    func startRequest()
    func parameterCheck() -> Bool
}

class HttpService {
    var queryParameter:Encodable?
    var bodyParameter:Encodable?
    weak var delegate:HttpServiceDelegate?
    
    func getHeader() -> HTTPHeaders {
        var header = HTTPHeaders()
        header.add(name: "request_time", value: String(Date().milliTimeIntervalSince1970))
        header.add(name: "device_id", value: UIDevice.current.identifierForVendor!.uuidString)
        header.add(name: "device", value: UIDevice.current.name)
        header.add(name: "os", value: UIDevice.current.systemName)
        header.add(name: "os_version", value: UIDevice.current.systemVersion)
        header.add(name: "request_id", value: UUID().uuidString)
        
        var headerStr = String(format: "%@%@%@%@%@%@",
                               header["request_time"]!,
                               header["device_id"]!,
                               header["device"]!,
                               header["os"]!,
                               header["os_version"]!,
                               header["request_id"]!)
        
        if let userToken = UserDefaults.sk_default.string(forKey: USER_DEFAULTS_USER_TOKEN) {
            header.add(name: "user_token", value: userToken)
            headerStr = headerStr.appending(userToken)
        }
        
        var queryParameterStr = JSON(queryParameter as Any).string
        var bodyParameterStr = JSON(bodyParameter as Any).string
        
        var requestStr = String(format: "%@%@%@",
                                queryParameterStr ?? "",
                                "skrestaurant_key",
                                bodyParameterStr ?? "")
        
        header.add(name: "reqeust_auth", value: (requestStr.data(using: .utf8)?.md5().toHexString())!)
        
        return header
    }
}



struct UserLoginBodyParameter:Encodable {
    var username:String?
    var password:String?
}

class UserLoginService:HttpService, HttpServiceProtocol {
    func parameterCheck() -> Bool {
        if let bodyParameter = bodyParameter as? UserLoginBodyParameter {
            return bodyParameter.username != nil
            && bodyParameter.password != nil
        }
        return false
    }
    
    func startRequest() {
        if !parameterCheck() {
            if delegate != nil {
                delegate?.requestCompleted(result: .failure, output: nil, error: SKHTTPError.HTTP_PARAMETER)
            }
            return
        }
        
        AF.request("\(HTTP_SERVER_ADDRESS)/user/login", method:.post, parameters: bodyParameter as? UserLoginBodyParameter, encoder: .json, headers: getHeader())
    }
    
    
}
