//
//  LoginViewController.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/06.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        toMainSplitView()
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
