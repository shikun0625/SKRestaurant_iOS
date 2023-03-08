//
//  LoginViewController.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/06.
//

import Foundation
import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        ProgressHUD.show(nil, interaction: false)
        let loginService = UserLoginService()
        loginService.delegate = self
        let input = UserLoginBodyParameter(username: userNameTextField.text, password: passwordTextField.text)
        loginService.bodyParameter = input
        loginService.startRequest()
        
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
    func requestCompleted(result: SKHttpRequestResult, output: Any?, error: Error?) {
        switch result {
        case .success:
            toMainSplitView()
        case .failure:
            ProgressHUD.showFailed(error?.localizedDescription, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}
