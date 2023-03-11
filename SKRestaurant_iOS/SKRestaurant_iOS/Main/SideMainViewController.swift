//
//  SideMainViewController.swift
//  SKRestaurant_iOS
//
//  Created by 施　こん on 2023/03/06.
//

import Foundation
import UIKit

class SideMainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        title = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
        
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        let alertView = UIAlertController(title: "退出登录", message: "确定退出吗？", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "退出", style: .destructive, handler: { [self] action in
            UserDefaults.sk_default.deleteToken()
            UserDefaults.sk_default.deleteExpiredDateTime()
            toLoginView()
        }))
        alertView.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alertView, animated: true)
    }
    
    private func toLoginView() -> Void {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "loginViewController")
        
        let scene:UIWindowScene = UIApplication.shared.connectedScenes.first { scene in
            return scene is UIWindowScene
        } as! UIWindowScene
        
        scene.keyWindow?.rootViewController = vc
    }
    
    private func showMateriel() -> Void {
        NotificationCenter.default.post(.SKShowMaterielViewNotification)
    }
}

extension SideMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "设置"
        case 2:
            return "管理"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "side_main_order_cell", for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "side_main_setting_cell", for: indexPath) as! SideMainSettingTableCell
            switch indexPath.row {
            case 0:
                cell.icon.image = UIImage(named: "icon_side_main_setting_menu")
                cell.title_label.text = "菜单"
            case 1:
                cell.icon.image = UIImage(named: "icon_side_main_setting_reserve")
                cell.title_label.text = "库存"
            case 2:
                cell.icon.image = UIImage(named: "icon_side_main_setting_pay")
                cell.title_label.text = "支付"
            case 3:
                cell.icon.image = UIImage(named: "icon_side_main_setting_takeout")
                cell.title_label.text = "外卖"
            case 4:
                cell.icon.image = UIImage(named: "icon_side_main_setting_personnel")
                cell.title_label.text = "人事"
            default:
                break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "side_main_setting_cell", for: indexPath) as! SideMainSettingTableCell
            switch indexPath.row {
            case 0:
                cell.icon.image = UIImage(named: "icon_side_main_setting_report")
                cell.title_label.text = "报表"
            case 1:
                cell.icon.image = UIImage(named: "icon_side_main_setting_schedule")
                cell.title_label.text = "班表"
            default:
                break
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            do {}
        case 1:
            switch indexPath.row {
            case 0:
                do {}
            case 1:
                showMateriel()
            case 2:
                do {}
            case 3:
                do {}
            case 4:
                do {}
            default:
                do {}
            }
        case 2:
            do {}
        default:
            break
        }
    }
}


class SideMainOrderTableCell: UITableViewCell {
  
}

class SideMainSettingTableCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title_label: UILabel!
 
}
