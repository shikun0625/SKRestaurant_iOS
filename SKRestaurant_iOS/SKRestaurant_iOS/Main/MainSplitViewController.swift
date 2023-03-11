//
//  MainSplitViewController.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/06.
//

import Foundation
import UIKit

class MainSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMaterielNotification), name: .SKShowMaterielViewNotificationName, object: nil)
    }
    
    @objc private func showMaterielNotification(notification:Notification) -> Void {
        let storyBoard = UIStoryboard(name: "Materiel", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "materielMain")
        
        setViewController(vc, for: .secondary)
    }
}
