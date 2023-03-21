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
    var amount:Float?
    var selectedMenuList:[String:Int] = [:]
    var orderType:Int = 0
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var PRButton: DesignableButton!
    @IBOutlet weak var cashButton: DesignableButton!
    @IBOutlet weak var cancelButton: DesignableButton!
    @IBOutlet weak var scanButton: DesignableButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var payAmountTextField: UITextField!
    @IBOutlet weak var cashFrameView: UIView!
    @IBOutlet weak var giveChangeLabel: UILabel!
    
    private var selectedPayType:Int?
    private var barCode:String?
    private var barCodeType:Int?
    
    private var orderId:String?
    private var payTradeNo:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payAmountTextField.delegate = self
        
        amountLabel.text = "订单金额：\(String(format: "%.2f", amount!))"
        
        startScanBarCode()
    }
    
    @IBAction func scanPressed(_ sender: DesignableButton?) {
        titleLable.text = "等待用户扫码"
        activityIndicator.startAnimating()
        selectedPayType = nil
        UIView.animate(withDuration: 0.3) {
            self.cashFrameView.alpha = 0
        }
        
        scanButton.isEnabled = false
        scanButton.backgroundColor = .systemGray5
        cashButton.isEnabled = true
        cashButton.backgroundColor = UIColor(named:"orderBlue")
        PRButton.isEnabled = true
        PRButton.backgroundColor = UIColor(named:"orderBlue")
        cancelButton.isEnabled = true
        cancelButton.backgroundColor = UIColor(named:"orderBlue")
        
        startScanBarCode()
    }
    
    @IBAction func cashPressed(_ sender: DesignableButton) {
        titleLable.text = "现金付款"
        activityIndicator.stopAnimating()
        payAmountTextField.text = String(format: "%.2f", amount!)
        giveChangeLabel.text = "0.00"
        selectedPayType = 0
        UIView.animate(withDuration: 0.3) {
            self.cashFrameView.alpha = 1
        }
        
        scanButton.isEnabled = true
        scanButton.backgroundColor = UIColor(named:"orderBlue")
        cashButton.isEnabled = false
        cashButton.backgroundColor = .systemGray5
        PRButton.isEnabled = true
        PRButton.backgroundColor = UIColor(named:"orderBlue")
        cancelButton.isEnabled = true
        cancelButton.backgroundColor = UIColor(named:"orderBlue")
        
    }
    
    @IBAction func publicRelationsPressed(_ sender: DesignableButton) {
        titleLable.text = "公共关系"
        activityIndicator.stopAnimating()
        payAmountTextField.text = "0.00"
        giveChangeLabel.text = "0.00"
        selectedPayType = 4
        UIView.animate(withDuration: 0.3) {
            self.cashFrameView.alpha = 1
        }
        
        scanButton.isEnabled = true
        scanButton.backgroundColor = UIColor(named:"orderBlue")
        cashButton.isEnabled = true
        cashButton.backgroundColor = UIColor(named:"orderBlue")
        PRButton.isEnabled = false
        PRButton.backgroundColor = .systemGray5
        cancelButton.isEnabled = true
        cancelButton.backgroundColor = UIColor(named:"orderBlue")
    }
    
    @IBAction func cancelPressed(_ sender: DesignableButton) {
        dismiss(animated: true)
    }
    
    @IBAction func payConfirmPressed(_ sender: DesignableButton) {
        if selectedPayType == 0 {
            payAmountTextField.resignFirstResponder()
            ProgressHUD.show(nil, interaction: false)
            let input = CreateOrderInput()
            input.payAmount = amount
            input.totalAmount = amount
            input.payType = selectedPayType
            input.menus = selectedMenuList
            input.type = orderType
            let error = OrderService(bodyParameter: input, delegate: self, sender: "finished").order()
            if error != nil {
                ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
            }
        } else if selectedPayType == 4 {
            payAmountTextField.resignFirstResponder()
            ProgressHUD.show(nil, interaction: false)
            let input = CreateOrderInput()
            input.payAmount = Float(payAmountTextField.text!)
            input.totalAmount = amount
            input.payType = selectedPayType
            input.menus = selectedMenuList
            input.type = orderType
            let error = OrderService(bodyParameter: input, delegate: self, sender: "finished").order()
            if error != nil {
                ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
            }
        }
    }
    
    private func pay() -> Void {
        scanButton.isEnabled = false
        scanButton.backgroundColor = .systemGray5
        cashButton.isEnabled = false
        cashButton.backgroundColor = .systemGray5
        PRButton.isEnabled = false
        PRButton.backgroundColor = .systemGray5
        cancelButton.isEnabled = false
        cancelButton.backgroundColor = .systemGray5
        
        if barCode!.count >= 16 && barCode!.count <= 24 {
            let temp = Int(barCode!.prefix(2))
            if temp != nil && temp! >= 25 && temp! <= 30  {
                barCodeType = 1
                titleLable.text = "正在使用支付宝支付"
                let input = CreateOrderInput()
                input.totalAmount = amount
                input.menus = selectedMenuList
                input.type = orderType
                let error = OrderService(bodyParameter: input, delegate: self, sender: "scanPay").order()
                if error != nil {
                    ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
                }
                return
            }
        } else if barCode!.count == 18 {
            let temp = Int(barCode!.prefix(2))
            if temp != nil && temp! >= 10 && temp! <= 15  {
                barCodeType = 2
                titleLable.text = "正在使用微信支付"
                let input = CreateOrderInput()
                input.totalAmount = amount
                input.menus = selectedMenuList
                input.type = orderType
                let error = OrderService(bodyParameter: input, delegate: self, sender: "scanPay").order()
                if error != nil {
                    ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
                }
                return
            }
        }
        scanButton.isEnabled = true
        scanButton.backgroundColor = UIColor(named:"orderBlue")
        cashButton.isEnabled = true
        cashButton.backgroundColor = UIColor(named:"orderBlue")
        PRButton.isEnabled = true
        PRButton.backgroundColor = UIColor(named:"orderBlue")
        cancelButton.isEnabled = true
        cancelButton.backgroundColor = UIColor(named:"orderBlue")
        activityIndicator.stopAnimating()
        titleLable.text = "二维码不正确"
    }
    
    private func startScanBarCode() -> Void {
        titleLable.text = "等待用户扫码"
        scanButton.isEnabled = false
        scanButton.backgroundColor = .systemGray5
        activityIndicator.startAnimating()
        //TODO: 调用扫码器扫描客户付款二维码
        
        
        //TEST: 现在模拟10秒后获得二维码
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.barCode = "28763443825664394"
            self.pay()
        }
    }
}

extension WaitingForPayViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "." || string == "" || Int(string) != nil  {
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.hasSuffix(".") {
            textField.text = textField.text?.appending("0")
        }
        let value = Float(textField.text!)
        textField.text = String(format: "%.2f", Float(textField.text!)!)
        if selectedPayType == 4 {
            giveChangeLabel.text = "0.00"
        } else if selectedPayType == 0 {
            if value! >= amount! {
                giveChangeLabel.text = String(format: "%.2f", value! - amount!)
            } else {
                textField.text = String(format: "%.2f", amount!)
                giveChangeLabel.text = "0.00"
            }
        }
    }
}

extension WaitingForPayViewController:HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .PostOrder {
                guard let action = sender else { return }
                if (action as! String == "finished") {
                    dismiss(animated: true) {
                        NotificationCenter.default.post(.SKResetOrderViewNotification)
                    }
                } else if (action as! String == "scanPay") {
                    let resultOutput = output as! CreateOrderOutput
                    orderId = resultOutput.resp.orderId
                    let input = PayInput()
                    input.barCode = barCode
                    input.barCodeType = barCodeType
                    input.amount = amount
                    input.orderId = orderId
                    let date = Date(timeIntervalSince1970: Double(resultOutput.resp.createTime!) / 1000.0)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    input.subject = resultOutput.resp.number?.appending(" ").appending(formatter.string(from: date))
                    let error = PayService(bodyParameter: input, delegate: self).pay()
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription, interaction: false)
                        scanPressed(nil)
                    }
                }
            } else if service == .PostPay {
                
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}
