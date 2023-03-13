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


protocol HttpServiceDelegate:AnyObject {
    func requestCompleted(request:Request, result:SKHttpRequestResult, output:Any?, error:Error?)
}

extension HttpServiceDelegate {
    func requestCompleted(result:SKHttpRequestResult, output:Any?, error:Error?) {
        log("未实现 requestCompleted")
    }
}

class HttpService {
    var responseType = HandyJSON.self
    var request:Request?
    var queryParameter:HttpParameter?
    var bodyParameter:HttpParameter?
    weak var delegate:HttpServiceDelegate?
    
    init(queryParameter: HttpParameter? = nil, bodyParameter: HttpParameter? = nil, delegate: HttpServiceDelegate? = nil) {
        self.queryParameter = queryParameter
        self.bodyParameter = bodyParameter
        self.delegate = delegate
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
    
    func startLogin() -> (Request?, Error?) {
        if !parameterCheck() {
            return (nil, SKHTTPError.HTTP_PARAMETER)
        }
        
        request = AF.request("\(HTTP_SERVER_ADDRESS)/user/login",requestModifier: { request in
            request.method = .post
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
                        self.delegate?.requestCompleted(request:self.request!, result: .success, output: output, error: nil)
                    } else {
                        self.delegate?.requestCompleted(request:self.request!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(request:self.request!, result: .failure, output: nil, error: error)
                }
            }
        })
        return (request, nil)
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
    
    func getMateriels() -> (Alamofire.Request?, Error?) {
        request = AF.request("\(HTTP_SERVER_ADDRESS)/materiel",requestModifier: { request in
            request.method = .get
            request.headers = self.getHeader()
        }).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                if self.delegate != nil {
                    let dataStr = String(data: response.value!, encoding: .utf8)
                    log(response.request?.url?.absoluteString as Any)
                    log("response data : \(dataStr ?? "")")
                    let output = UpdateMaterielOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(request:self.request!, result: .success, output: output, error: nil)
                    } else {
                        self.delegate?.requestCompleted(request:self.request!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(request:self.request!, result: .failure, output: nil, error: error)
                }
            }
        })
        return (request, nil)
    }
    
    func createMateriel() -> (Alamofire.Request?, Error?) {
        request = AF.request("\(HTTP_SERVER_ADDRESS)/materiel",requestModifier: { request in
            request.method = .post
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
                    let output = HttpServiceOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(request:self.request!, result: .success, output: output, error: nil)
                    } else {
                        self.delegate?.requestCompleted(request:self.request!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(request:self.request!, result: .failure, output: nil, error: error)
                }
            }
        })
        return (request, nil)
    }
    
    func updateMateriel() -> (Alamofire.Request?, Error?) {
        request = AF.request("\(HTTP_SERVER_ADDRESS)/materiel",requestModifier: { request in
            request.method = .put
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
                    let output = HttpServiceOutput.deserialize(from: dataStr)
                    if output != nil && output?.status == 200 {
                        self.delegate?.requestCompleted(request:self.request!, result: .success, output: output, error: nil)
                    } else {
                        self.delegate?.requestCompleted(request:self.request!, result: .failure, output: output, error: SKHTTPError.HTTP_SERVER_ERROR)
                    }
                }
            case let .failure(error):
                if self.delegate != nil {
                    self.delegate?.requestCompleted(request:self.request!, result: .failure, output: nil, error: error)
                }
            }
        })
        return (request, nil)
    }
}
