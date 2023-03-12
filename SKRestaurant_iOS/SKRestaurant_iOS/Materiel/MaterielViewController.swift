//
//  MaterielViewController.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/11/R5.
//

import Foundation
import UIKit
import Alamofire
import ProgressHUD
import MJRefresh

class MaterielViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var getMaterielRequest:Request?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header = MJRefreshNormalHeader {
            self.getMateriels()
            
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .SKMaterielViewRefreshNotificationName, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .SKMaterielViewRefreshNotificationName, object: nil)
    }
    
    @objc func refresh(notification:Notification) -> Void {
        tableView.mj_header?.beginRefreshing()
    }
    
    func getMateriels() -> Void {
        var error:Error?
        (getMaterielRequest, error) = MaterielService(delegate: self).getMateriels()
        if error != nil {
            
        }
    }
}

extension MaterielViewController: HttpServiceDelegate {
    func requestCompleted(request: Alamofire.Request, result: SKHttpRequestResult, output: Any?, error: Error?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if request == getMaterielRequest {
                tableView.mj_header?.endRefreshing()
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
    
    
}


class MaterielAddViewController: UIViewController {
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var conformButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    private var selectedUnit:Int?
    private var selectedType:Int?
    private var createMaterielRequest:Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitButton.menu = {
            var actions:[UIAction] = []
            var action = UIAction(title: "份", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 0
            })
            actions.append(action)
            
            action = UIAction(title: "块", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 1
            })
            actions.append(action)
            
            action = UIAction(title: "瓶", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 2
            })
            actions.append(action)
            
            action = UIAction(title: "碗", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 3
            })
            actions.append(action)
            
            action = UIAction(title: "个", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 4
            })
            actions.append(action)
            
            action = UIAction(title: "包", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 5
            })
            actions.append(action)
            
            action = UIAction(title: "克", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 6
            })
            actions.append(action)
            
            action = UIAction(title: "斤", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 7
            })
            actions.append(action)
            
            action = UIAction(title: "箱", handler: { action in
                self.unitButton.setTitle(action.title, for: .normal)
                self.selectedUnit = 8
            })
            actions.append(action)
            
            return UIMenu(children: actions)
        }()
        
        typeButton.menu = {
            var actions:[UIAction] = []
            var action = UIAction(title: "可销售", handler: { action in
                self.typeButton.setTitle(action.title, for: .normal)
                self.selectedType = 0
            })
            actions.append(action)
            
            action = UIAction(title: "不可销售", handler: { action in
                self.typeButton.setTitle(action.title, for: .normal)
                self.selectedType = 1
            })
            actions.append(action)
            
            return UIMenu(children: actions)
            
        }()
    }
    
    private func checkConformButtonStatus() -> Void {
        let name = nameTextField.text
        conformButton.isEnabled = name!.count > 0 && selectedUnit != nil && selectedType != nil
    }
    
    @IBAction func conformPressed(_ sender: UIButton) {
        errorMessageLabel.text = ""
        if nameTextField.text?.count == 0 {
            errorMessageLabel.text = "请输入名称"
            return
        }
        if selectedUnit == nil {
            errorMessageLabel.text = "请选择单位"
            return
        }
        if selectedType == nil {
            errorMessageLabel.text = "请选择类型"
            return
        }
        ProgressHUD.show(nil, interaction: false)
        let input = CreateMaterielInput()
        input.name = nameTextField.text
        input.unit = selectedUnit
        input.type = selectedType
        input.remark = remarkTextField.text
        var error:Error?
        (createMaterielRequest, error) = MaterielService(bodyParameter: input, delegate: self).createMateriel()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription, interaction: false)
        }
    }
}

extension MaterielAddViewController: HttpServiceDelegate {
    func requestCompleted(request: Alamofire.Request, result: SKHttpRequestResult, output: Any?, error: Error?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if request == createMaterielRequest {
                dismiss(animated: true) {
                    NotificationCenter.default.post(.SKMaterielViewRefreshNotification)
                }
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
    
    
}

