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
    func toDictionary() -> [String:String]? {
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

//MARK: - UserLoginService
class UserLoginBodyParameter:HttpParameter {
    var username:String?
    var password:String?
}

class UserLoginOutput:HttpServiceOutput {
    var resp:UserLoginResp?
}

class UserLoginResp:HttpServiceResp {
    var authToken:String?
    var expiredTime:Int64?
}

class UserLoginService:HttpService {
    func parameterCheck() -> Bool {
        if let bodyParameter = bodyParameter as? UserLoginBodyParameter {
            if let username = bodyParameter.username {
                if username.count == 0 {
                    return false
                }
            }
            if let password = bodyParameter.password {
                if password.count == 0 {
                    return false
                }
            }
            
            bodyParameter.password = bodyParameter.password?.md5()
            return true
        }
        return false
    }
    
    func startLogin() -> Error? {
        service = .UserLogin
        if !parameterCheck() {
            return SKHTTPError.HTTP_PARAMETER
        }
        
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)",requestModifier: { request in
            request.method = self.service?.method
            request.headers = self.getHeader()
            request.httpBody = self.bodyParameter?.toJSONString()?.data(using: .utf8)
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    let output = UserLoginOutput.deserialize(from: dataStr)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(service: .UserLogin, result: .success, output: output, error: nil, sender: self.sender)
                    } else {
                        self.delegate?.requestCompleted(service: .UserLogin, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR, sender: self.sender)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(service: .UserLogin, result: .failure, output: nil, error: error, sender: self.sender)
                }
            }
            
            self.sender = nil
            self.delegate = nil
            self.service = nil
        })
        return nil
    }
    
    
}

//MARK: - MaterielService
class GetMaterielInput: HttpQueryInput {
    var type:Int?
    
    override func toDictionary() -> [String : String]? {
        var dic = [String : String]()
        if let type = type {
            dic["type"] = String(type)
        }
        return dic
    }
}

class GetMaterielOutput: HttpServiceOutput {
    var resp = GetMaterielResp()
    
}

class GetMaterielResp: HttpServiceResp {
    var materiels:[Materiel] = []
   
}

class Materiel: HandyJSON {
    var id:Int?
    var name:String?
    var type:Int?
    var unit:Int?
    var remark:String?
    var count:Int?
    var createTime:Int64?
    
    required init() {
        
    }
}

class CreateMaterielInput:HttpParameter {
    var name:String?
    var remark:String?
    var type:Int?
    var unit:Int?
}

class CreateMaterielOutput:HttpServiceOutput {
    var resp = Materiel()
}

class UpdateMaterielInput:HttpParameter {
    var id:Int?
    var name:String?
    var remark:String?
    var type:Int?
    var unit:Int?
}

class UpdateMaterielOutput: HttpServiceOutput {
    var resp = Materiel()
    
}

class MaterielService:HttpService {
    
    func getMateriels() -> Error? {
        service = .GetMateriels
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)", parameters: queryParameter?.toDictionary(), requestModifier: { request in
            request.method = self.service?.method
            request.headers = self.getHeader()
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    let output = GetMaterielOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(service: self.service!, result: .success, output: output, error: nil, sender: self.sender)
                    } else {
                        self.delegate?.requestCompleted(service: self.service!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR, sender: self.sender)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(service: self.service!, result: .failure, output: nil, error: error, sender: self.sender)
                }
            }
            self.sender = nil
            self.delegate = nil
            self.service = nil
        })
        return nil
    }
    
    func createMateriel() -> Error? {
        service = .CreateMateriel
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)",requestModifier: { request in
            request.method = self.service?.method
            request.headers = self.getHeader()
            let bodyJson = self.bodyParameter?.toJSONString()
            request.httpBody = bodyJson?.data(using: .utf8)
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    let output = CreateMaterielOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(service: self.service!, result: .success, output: output, error: nil, sender: self.sender)
                    } else {
                        self.delegate?.requestCompleted(service: self.service!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR, sender: self.sender)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(service: self.service!, result: .failure, output: nil, error: error, sender: self.sender)
                }
            }
            self.sender = nil
            self.delegate = nil
            self.service = nil
        })
        return nil
    }
    
    func updateMateriel() -> Error? {
        service = .UpdateMateriel
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)",requestModifier: { request in
            request.method = self.service?.method
            request.headers = self.getHeader()
            let bodyJson = self.bodyParameter?.toJSONString()
            request.httpBody = bodyJson?.data(using: .utf8)
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    let output = UpdateMaterielOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(service: self.service!, result: .success, output: output, error: nil, sender: self.sender)
                    } else {
                        self.delegate?.requestCompleted(service: self.service!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR, sender: self.sender)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(service: self.service!, result: .failure, output: nil, error: error, sender: self.sender)
                }
            }
            self.sender = nil
            self.delegate = nil
            self.service = nil
        })
        return nil
    }
}

//MARK: - MaterielActionService
class CreateMaterielActionInput: HttpParameter {
    var materielId:Int?
    var delta:Int?
    var actionType:Int?
    var reason:Int?
}

class CreateMaterielActionOutput:HttpServiceOutput {
    var resp = Materiel()
}

class MaterielActionService: HttpService {
    func createMaterielAction() -> Error? {
        service = .CreateMaterielAction
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)",requestModifier: { request in
            request.method = self.service?.method
            request.headers = self.getHeader()
            let bodyJson = self.bodyParameter?.toJSONString()
            request.httpBody = bodyJson?.data(using: .utf8)
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    let output = CreateMaterielActionOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(service: self.service!, result: .success, output: output, error: nil, sender: self.sender)
                    } else {
                        self.delegate?.requestCompleted(service: self.service!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR, sender: self.sender)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(service: self.service!, result: .failure, output: nil, error: error, sender: self.sender)
                }
            }
            self.sender = nil
            self.delegate = nil
            self.service = nil
        })
        return nil
    }
}

//MARK: - MealsService

class CreateMealsInput: HttpParameter {
    var name:String?
    var status:Int?
    var value:Float?
    var materielIds:[Int]?
    var remark:String?
}

class Meals: HandyJSON {
    var id:Int?
    var name:String?
    var status:Int?
    var value:Float?
    var materiels:[Materiel]?
    var remark:String?
    var createTime:Int64?
    
    required init() {
        
    }
}

class CreateMealsOutput: HttpServiceOutput {
    var resp = Meals()
}

class MealsService: HttpService {
    func createMeals() -> Error? {
        service = .CreateMeals
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)",requestModifier: { request in
            request.method = self.service?.method
            request.headers = self.getHeader()
            let bodyJson = self.bodyParameter?.toJSONString()
            request.httpBody = bodyJson?.data(using: .utf8)
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    let output = CreateMaterielActionOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(service: self.service!, result: .success, output: output, error: nil, sender: self.sender)
                    } else {
                        self.delegate?.requestCompleted(service: self.service!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR, sender: self.sender)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(service: self.service!, result: .failure, output: nil, error: error, sender: self.sender)
                }
            }
            self.sender = nil
            self.delegate = nil
            self.service = nil
        })
        return nil
    }
}
