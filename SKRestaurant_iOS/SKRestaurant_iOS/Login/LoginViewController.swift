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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var loginRequest:Request?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var date = UserDefaults.sk_default.getExpiredDateTime()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        ProgressHUD.show(nil, interaction: false)
        let loginService = UserLoginService()
        loginService.delegate = self
        let input = UserLoginBodyParameter()
        input.username = userNameTextField.text
        input.password = passwordTextField.text
        loginService.bodyParameter = input
        var error:Error?
        (loginRequest, error) = loginService.startRequest()
        if error != nil {
            ProgressHUD.showFailed(error!.localizedDescription, interaction: false)
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
    func requestCompleted(request: Request, result: SKHttpRequestResult, output: Any?, error: Error?) {
        switch result {
        case .success:
            if request == loginRequest {
                let resultOutput:UserLoginOutput = output as! UserLoginOutput
                UserDefaults.sk_default.setToken(token: resultOutput.resp!.authToken!)
                UserDefaults.sk_default.setExpiredDateTime(date: Date(timeIntervalSince1970: Double((resultOutput.resp?.expiredTime)!) / 1000.0))
                UserDefaults.sk_default.setUsername(username: userNameTextField.text!)
                toMainSplitView()
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}
