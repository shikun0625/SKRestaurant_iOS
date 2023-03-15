//
//  UserService.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import Alamofire

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

class UserService:HttpService {
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

