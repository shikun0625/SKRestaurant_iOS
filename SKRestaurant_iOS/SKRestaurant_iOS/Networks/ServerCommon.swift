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
        return "http://192.168.0.131:8080/SKRestaurant_Server"
    }
}()

enum SKHttpRequestResult {
    case success
    case failure
    case cancel
    case uploading
    case downloading
}

class SKHTTPService: Equatable {
    static func == (lhs: SKHTTPService, rhs: SKHTTPService) -> Bool {
        return lhs.path == rhs.path && lhs.method == rhs.method
    }
    
    public static let UserLogin = SKHTTPService(path: "/user/login", method: .post)
    public static let GetMateriels = SKHTTPService(path: "/materiel", method: .get)
    public static let CreateMateriel = SKHTTPService(path: "/materiel", method: .post)
    public static let UpdateMateriel = SKHTTPService(path: "/materiel", method: .put)
    public static let CreateMaterielAction = SKHTTPService(path: "/materiel/action", method: .post)
    public static let CreateMeals = SKHTTPService(path: "/meals", method: .post)
    public static let GetMealses = SKHTTPService(path: "/meals", method: .get)
    public static let UpdateMeals = SKHTTPService(path: "/meals", method: .put)
    public static let GetMenu = SKHTTPService(path: "/menu", method: .get)
    public static let PostOrder = SKHTTPService(path: "/order", method: .post)
    public static let UpdateOrder = SKHTTPService(path: "/order", method: .put)
    
    var path:String = ""
    var method:HTTPMethod = .options
    
    init(path: String, method: HTTPMethod) {
        self.path = path
        self.method = method
    }
}


public enum SKHTTPError: Int, Error {
    case HTTP_PARAMETER = 2501
    case HTTP_SERVER_ERROR = 2502
}

extension SKHTTPError: CustomNSError {
    
    /// return the error domain of SwiftyJSONError
    public static var errorDomain: String { return "sk.restaurant.HTTP" }
    
    /// return the error code of SwiftyJSONError
    public var errorCode: Int { return self.rawValue }
    
    /// return the userInfo of SwiftyJSONError
    public var errorUserInfo: [String: Any] {
        switch self {
        case .HTTP_PARAMETER:
            return [NSLocalizedDescriptionKey: "请求参数错误."]
        case .HTTP_SERVER_ERROR:
            return [NSLocalizedDescriptionKey: "服务器出错."]
        }
    }
}

//MARK: - HttpService
protocol HttpServiceDelegate:AnyObject {
    func requestCompleted(service:SKHTTPService, result:SKHttpRequestResult, output:Any?, error:Error?, sender:Any?)
}

extension HttpServiceDelegate {
    func requestCompleted(result:SKHttpRequestResult, output:Any?, error:Error?) {
        log("未实现 requestCompleted")
    }
}

class HttpService {
    var service:SKHTTPService?
    var responseType = HandyJSON.self
    var queryParameter:HttpQueryInput?
    var bodyParameter:HttpParameter?
    var sender:Any?
    weak var delegate:HttpServiceDelegate?
    
    init(queryParameter: HttpQueryInput? = nil, bodyParameter: HttpParameter? = nil, delegate: HttpServiceDelegate? = nil, sender:Any? = nil) {
        self.queryParameter = queryParameter
        self.bodyParameter = bodyParameter
        self.delegate = delegate
        self.sender = sender
    }
    
    func getHeader() -> HTTPHeaders {
        var header = HTTPHeaders()
        header.add(name: "request_time", value: String(Date().milliTimeIntervalSince1970))
        header.add(name: "device_id", value: UIDevice.current.identifierForVendor!.uuidString)
        header.add(name: "device", value: UIDevice.current.model)
        header.add(name: "os", value: UIDevice.current.systemName)
        header.add(name: "os_version", value: UIDevice.current.systemVersion)
        header.add(name: "request_id", value: UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        
        var headerStr = String(format: "%@%@%@%@%@%@",
                               header["request_time"]!,
                               header["device_id"]!,
                               header["device"]!,
                               header["os"]!,
                               header["os_version"]!,
                               header["request_id"]!)
        
        if let userToken = UserDefaults.sk_default.getToken() {
            header.add(name: "user_token", value: userToken)
            headerStr = headerStr.appending(userToken)
        }
        
        let bodyParameterStr = bodyParameter?.toJSONString()
        
        let requestStr = String(format: "%@%@%@",
                                "skrestaurant_key",
                                bodyParameterStr ?? "",
                                headerStr
        )
        
        header.add(name: "request_auth", value: (requestStr.md5()))
        
        return header
    }
}

class HttpQueryInput {
    func toDictionary() -> [String:Encodable]? {
        return nil
    }
}

class HttpServiceOutput:HandyJSON {
    var status:Int?
    var errorMessage:String?
    required init() {
        
    }
}

class HttpServiceResp:HandyJSON {
    
    required init() {
        
    }
}


class HttpParameter:HandyJSON {
    required init() {
        
    }
}

