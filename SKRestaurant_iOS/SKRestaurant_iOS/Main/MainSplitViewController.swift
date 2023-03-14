//
//  MainSplitViewController.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/06.
//

import Foundation
import UIKit

class MainSplitViewController: UISplitViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showMaterielNotification), name: .SKShowMaterielViewNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMealsNotification), name: .SKShowMealsViewNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .SKShowMaterielViewNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SKShowMealsViewNotification, object: nil)
    }
   
    
    @objc private func showMaterielNotification(notification:Notification) -> Void {
        let naviViewController = viewController(for: .secondary) as! UINavigationController
        let viewControllers = naviViewController.viewControllers
        if viewControllers.count > 0 && viewControllers.first is MaterielViewController {
            return
        }

        let storyBoard = UIStoryboard(name: "Materiel", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "materielRoot")

        naviViewController.setViewControllers([vc], animated: false)
    }
    
    @objc private func showMealsNotification(notification:Notification) -> Void {
        let naviViewController = viewController(for: .secondary) as! UINavigationController
        let viewControllers = naviViewController.viewControllers
        if viewControllers.count > 0 && viewControllers.first is MealsViewController {
            return
        }

        let storyBoard = UIStoryboard(name: "Meals", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "mealsRoot")

        naviViewController.setViewControllers([vc], animated: false)
    }
}
