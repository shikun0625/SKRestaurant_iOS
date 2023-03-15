//
//  MealsService.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import HandyJSON
import Alamofire

class CreateMealsInput: HttpParameter {
    var name:String?
    var status:Int?
    var value:Float?
    var type:Int?
    var materielIds:[Int]?
    var remark:String?
}

class Meals: HandyJSON {
    var id:Int?
    var name:String?
    var type:Int?
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

class GetMealsesOutput: HttpServiceOutput {
    var resp = GetMealsesResp()
    
}

class GetMealsesResp: HttpServiceResp {
    var mealses:[Meals] = []
   
}

class UpdateMealsInput:HttpParameter {
    var id:Int?
    var value:Float?
    var status:Int?
}

class UpdateMealsOutput: HttpServiceOutput {
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
                    let output = CreateMealsOutput.deserialize(from: dataStr)
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
    
    func updateMeals() -> Error? {
        service = .UpdateMeals
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
                    let output = UpdateMealsOutput.deserialize(from: dataStr)
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
    
    func getMealses() -> Error? {
        service = .GetMealses
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
                    let output = GetMealsesOutput.deserialize(from: dataStr)
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
