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
    var materielsData:[Materiel] = []
    var getMaterielRequest:Request?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MaterielEditViewController {
            let destination = segue.destination as! MaterielEditViewController
            destination.materielInfo = (sender as! Materiel)
        }
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
                
                let result = output as! GetMaterielOutput
                self.materielsData = result.resp.materiels
                self.tableView.reloadData()
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
    
    
}

extension MaterielViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materielsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MaterielTableViewCell = tableView.dequeueReusableCell(withIdentifier: "materielCell", for: indexPath) as! MaterielTableViewCell
        let data = materielsData[indexPath.row]
        cell.nameLabel.text = data.name
        cell.typeLabel.text = convertMaterielTypeToString(type: data.type!)
        cell.remarkLabel.text = data.remark
        cell.countLabel.text = "\(String(data.count!))\(convertUnitToString(unit: data.unit!))"
        
        cell.inputButton.isEnabled = data.type! < 2
        cell.outputButton.isEnabled = data.type! < 2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let invalidAction:UIContextualAction?
        let data = materielsData[indexPath.row]
        switch data.type {
        case 2:
            // 无效状态
            invalidAction = UIContextualAction(style: .destructive, title: "有效") { action, sourceView, completionHandler in
                completionHandler(true)
            }
            invalidAction?.backgroundColor = .green
        default:
            // 有效状态
            invalidAction = UIContextualAction(style: .destructive, title: "无效") { action, sourceView, completionHandler in
                completionHandler(true)
            }
        }
        let editAction = UIContextualAction(style: .normal, title: "编辑") { action, sourceView, completionHandler in
            self.performSegue(withIdentifier: "toEditView", sender: self.materielsData[indexPath.row])
            completionHandler(true)
        }
        
        
        return UISwipeActionsConfiguration(actions: [editAction, invalidAction!])
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
            for i in 0...8 {
                let action = UIAction(title: convertUnitToString(unit: i), handler: { action in
                    self.unitButton.setTitle(action.title, for: .normal)
                    self.selectedUnit = i
                })
                actions.append(action)
            }
            
            return UIMenu(children: actions)
        }()
        
        typeButton.menu = {
            var actions:[UIAction] = []
            for i in 0...1 {
                let action = UIAction(title: convertMaterielTypeToString(type: i), handler: { action in
                    self.typeButton.setTitle(action.title, for: .normal)
                    self.selectedType = i
                })
                actions.append(action)
            }
            
            return UIMenu(children: actions)
            
        }()
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

class MaterielTableViewCell: UITableViewCell {
    
    @IBOutlet weak var outputButton: DesignableButton!
    @IBOutlet weak var inputButton: DesignableButton!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}


class MaterielEditViewController: UIViewController {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    
    var materielInfo: Materiel?
    
    private var updateMaterielRequest:Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = materielInfo?.name
        
        unitButton.menu = {
            var actions:[UIAction] = []
            
            for i in 0...8 {
                let action = UIAction(title: convertUnitToString(unit: i), handler: { action in
                    self.unitButton.setTitle(action.title, for: .normal)
                    self.materielInfo?.unit = i
                })
                actions.append(action)
            }
            
            return UIMenu(children: actions)
        }()
        
        unitButton.setTitle(convertUnitToString(unit: (materielInfo?.unit)!), for: .normal)
    }
    
    @IBAction func conformPressed(_ sender: UIButton) {
        errorMessageLabel.text = ""
        if nameTextField.text?.count == 0 {
            errorMessageLabel.text = "请输入名称"
            return
        }
   
        ProgressHUD.show(nil, interaction: false)
        let input = UpdateMaterielInput()
        input.id = materielInfo?.id
        input.name = nameTextField.text
        input.unit = materielInfo?.unit
        input.type = materielInfo?.type
        input.remark = remarkTextField.text
        var error:Error?
        (updateMaterielRequest, error) = MaterielService(bodyParameter: input, delegate: self).updateMateriel()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription, interaction: false)
        }
    }
}

extension MaterielEditViewController: HttpServiceDelegate {
    
}
