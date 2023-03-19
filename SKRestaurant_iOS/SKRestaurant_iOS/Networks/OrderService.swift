//
//  OrderService.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/18/R5.
//

import Foundation
import Alamofire
import HandyJSON

class CreateOrderInput: HttpParameter {
    var menus:[String:Int]?
    var totalAmount:Float?
    var type:Int?
}

class CreateOrderOutput: HttpServiceOutput {
    var resp = Order()
}

class Order: HandyJSON {
    var orderId:String?
    var menus:[String:Int]?
    var totalAmount:Float?
    var type:Int?
    var createTime:Int64?
    var number:String?
    var status:Int?
    var takeoutPlatform:Int?
    var takeoutStatus:Int?
    var payType:Int?
    var remark:String?
    var takeoutOrder:String?
    
    required init() {
        
    }
}

class UpdateOrderInput: HttpParameter {
    var orderId:String?
    var status:Int?
    var payType:Int?
}

class UpdateOrderOutput: HttpServiceOutput {
    var resp = Order()
}

class OrderService: HttpService {
    func order() -> Error? {
        service = .PostOrder
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)", requestModifier: { request in
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
                    let output = CreateOrderOutput.deserialize(from: dataStr)
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
    
    func updateOrder() -> Error? {
        service = .UpdateOrder
        AF.request("\(HTTP_SERVER_ADDRESS)\(service!.path)", requestModifier: { request in
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
                    let output = UpdateOrderOutput.deserialize(from: dataStr)
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
