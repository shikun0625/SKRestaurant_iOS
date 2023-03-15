//
//  MaterielService.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import Alamofire
import HandyJSON

class GetMaterielInput: HttpQueryInput {
    var type:Int?
    
    override func toDictionary() -> [String : Encodable]? {
        var dic = [String : Encodable]()
        if let type = type {
            dic["type"] = type
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
