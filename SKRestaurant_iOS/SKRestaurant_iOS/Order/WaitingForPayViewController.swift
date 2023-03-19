//
//  WaitForPayViewController.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/19/R5.
//

import Foundation
import UIKit
import ProgressHUD

class WaitingForPayViewController: UIViewController {
    var orderId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ProgressHUD.show(nil, interaction: false)
            let input = UpdateOrderInput()
            input.orderId = self.orderId
            input.status = 1
            let error = OrderService(bodyParameter: input, delegate: self).updateOrder()
            if error != nil {
                ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
            }
        }
    }
    
    @IBAction func cashPressed(_ sender: DesignableButton) {
        ProgressHUD.show(nil, interaction: false)
        let input = UpdateOrderInput()
        input.orderId = self.orderId
        input.status = 8
        input.payType = 0
        let error = OrderService(bodyParameter: input, delegate: self, sender: "cash").updateOrder()
        if error != nil {
            ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
        }
    }
    
    @IBAction func publicRelationsPressed(_ sender: DesignableButton) {
        ProgressHUD.show(nil, interaction: false)
        let input = UpdateOrderInput()
        input.orderId = self.orderId
        input.status = 8
        input.payType = 4
        let error = OrderService(bodyParameter: input, delegate: self, sender: "PR").updateOrder()
        if error != nil {
            ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
        }
    }
    
    @IBAction func cancelPressed(_ sender: DesignableButton) {
        ProgressHUD.show(nil, interaction: false)
        let input = UpdateOrderInput()
        input.orderId = self.orderId
        input.status = 5
        let error = OrderService(bodyParameter: input, delegate: self, sender: "cancel").updateOrder()
        if error != nil {
            ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
        }
    }
}

extension WaitingForPayViewController:HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .UpdateOrder {
                guard let action = sender else { return }
                if action as! String == "cancel" {
                    self.dismiss(animated: true)
                } else if (action as! String == "cash") {
                    self.dismiss(animated: true)
                } else if (action as! String == "PR") {
                    self.dismiss(animated: true)
                }
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}
