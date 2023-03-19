//
//  MenuService.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import HandyJSON
import Alamofire

class GetMenuOutput: HttpServiceOutput {
    var resp = GetMenuResp()
}

class GetMenuResp: HttpServiceResp {
    var menus:[Menu] = []
    var materiels:[Materiel] = []
}

class Menu: HandyJSON {
    var id:Int?
    var name:String?
    var type:Int?
    var value:Float?
    var materielIds:[Int] = []
    
    required init() {
        
    }
}

class MenuService: HttpService {
    func getMenu() -> Error? {
        service = .GetMenu
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
                    let output = GetMenuOutput.deserialize(from: dataStr)
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
