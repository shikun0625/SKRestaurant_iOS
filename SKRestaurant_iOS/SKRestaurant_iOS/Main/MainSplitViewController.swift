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
        showOrderNotification(notification: .SKShowOrderViewNotification)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showMaterielNotification), name: .SKShowMaterielViewNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMealsNotification), name: .SKShowMealsViewNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOrderNotification), name: .SKShowOrderViewNotificationName, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .SKShowMaterielViewNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SKShowMealsViewNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SKShowOrderViewNotificationName, object: nil)
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
    
    @objc private func showOrderNotification(notification:Notification) -> Void {
        let naviViewController = viewController(for: .secondary) as! UINavigationController
        let viewControllers = naviViewController.viewControllers
        if viewControllers.count > 0 && viewControllers.first is OrderViewController {
            return
        }

        let storyBoard = UIStoryboard(name: "Order", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "orderRoot")

        naviViewController.setViewControllers([vc], animated: false)
        hide(.primary)
    }
}
