//
//  LoginViewController.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/06.
//

import Foundation
import UIKit
import ProgressHUD
import Alamofire
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var faceIdButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        let username = UserDefaults.sk_default.getUsername()

        if username != nil {
            userNameTextField.text = username
        }
        
        faceIdAuthentication()
        
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        login(username: userNameTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func faceIdPressed(_ sender: UIButton) {
       faceIdAuthentication()
    }
    
    private func login(username:String, password:String) {
        ProgressHUD.show(nil, interaction: false)
        let input = UserLoginBodyParameter()
        input.username = username
        input.password = password
        var error = UserLoginService(bodyParameter: input, delegate: self).startLogin()
        if error != nil {
            ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
        }
    }
    
    private func faceIdAuthentication() {
        let username = UserDefaults.sk_default.getUsername()
        let passwrod = UserDefaults.sk_default.getPassword()
        
        if username != nil && passwrod != nil {
            let laContext = LAContext()
            var error:NSError?;
            if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                faceIdButton.isEnabled = true
                laContext.localizedFallbackTitle = "请使用账号密码登录"
                laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "验证登录权限") { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.passwordTextField.text = passwrod
                            self.login(username: username!, password: passwrod!)
                        } else {
                            UserDefaults.sk_default.deletePassword()
                            self.faceIdButton.isEnabled = false
                        }
                    }
                }
        } else {
            faceIdButton.isEnabled = false
            }
        }
    }
    
    private func toMainSplitView() -> Void {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "mainSplitViewController")
        
        let scene:UIWindowScene = UIApplication.shared.connectedScenes.first { scene in
            return scene is UIWindowScene
        } as! UIWindowScene
        
        scene.keyWindow?.rootViewController = vc
    }
}

extension LoginViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == SKHTTPService.UserLogin {
                let resultOutput:UserLoginOutput = output as! UserLoginOutput
                UserDefaults.sk_default.setToken(token: resultOutput.resp!.authToken!)
                UserDefaults.sk_default.setExpiredDateTime(date: Date(timeIntervalSince1970: Double((resultOutput.resp?.expiredTime)!) / 1000.0))
                UserDefaults.sk_default.setUsername(username: userNameTextField.text!)
                UserDefaults.sk_default.setPassword(password: passwordTextField.text!)
                toMainSplitView()
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            loginPressed(loginButton)
        default:
            break
        }
        
        return false
    }
}

