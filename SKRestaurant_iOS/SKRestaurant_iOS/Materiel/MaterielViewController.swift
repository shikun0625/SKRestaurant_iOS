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
import IQKeyboardManagerSwift

class MaterielViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var materielsData:[Materiel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let header = MJRefreshNormalHeader { [unowned self] in
            self.getMateriels()
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(materielAdded), name: .SKMaterielAddedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(materielUpdated), name: .SKMaterielUpdatedNotificationName, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .SKMaterielAddedNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SKMaterielUpdatedNotificationName, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MaterielEditViewController {
            let destination = segue.destination as! MaterielEditViewController
            if let userInfo: [Any] = sender as? [Any] {
                destination.materielInfo = (userInfo[0] as! Materiel)
                destination.indexPath = (userInfo[1] as! IndexPath)
            }
        } else if segue.destination is MaterielActionViewController {
            if let userInfo: [Any] = sender as? [Any] {
                let destination = segue.destination as! MaterielActionViewController
                destination.actionType = userInfo[0] as! Int
                let indexPath:IndexPath = userInfo[1] as! IndexPath
                destination.materiel = materielsData[indexPath.row]
                destination.indexPath = indexPath
            }
        }
    }
    
    @objc func materielAdded(notification:Notification) -> Void {
        materielsData.append(notification.object as! Materiel)
        tableView.insertRows(at: [IndexPath(row: materielsData.count - 1, section: 0)], with: .right)
    }
    
    @objc func materielUpdated(notification:Notification) -> Void {
        let object:[Any] = notification.object as! [Any]
        let indexPath:IndexPath = object[1] as! IndexPath
        let materiel:Materiel = object[0] as! Materiel
        materielsData[indexPath.row] = materiel
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func getMateriels() -> Void {
        let error = MaterielService(delegate: self).getMateriels()
        if error != nil {
            tableView.mj_header?.endRefreshing()
        }
    }
}

extension MaterielViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .GetMateriels {
                tableView.mj_header?.endRefreshing()
                let result = output as! GetMaterielOutput
                materielsData = result.resp.materiels
                tableView.reloadData()
            } else if service == .UpdateMateriel {
                ProgressHUD.dismiss()
                let indexPath:IndexPath = sender as! IndexPath
                let materiel:Materiel = (output as! UpdateMaterielOutput).resp
                materielsData[indexPath.row] = materiel
                tableView.reloadRows(at: [indexPath], with: .automatic)
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
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var invalidAction:UIContextualAction! = nil
        let data = materielsData[indexPath.row]
        
        switch data.type {
        case 0:
            invalidAction = UIContextualAction(style: .destructive, title: "不可售") { action, sourceView, completionHandler in
                let alert = UIAlertController(title: "请确认", message: "要设置成不可销售状态吗？相关联的菜品将会不可用。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { action in
                    ProgressHUD.show(nil, interaction: false)
                    let input = UpdateMaterielInput()
                    input.id = data.id
                    input.name = data.name
                    input.unit = data.unit
                    input.type = 1
                    input.remark = data.remark
                    let error = MaterielService(bodyParameter: input, delegate: self, sender: indexPath).updateMateriel()
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription, interaction: false)
                    }
                    completionHandler(true)
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                self.present(alert, animated: true)
                completionHandler(true)
            }
        case 1:
            invalidAction = UIContextualAction(style: .destructive, title: "可售") { action, sourceView, completionHandler in
                ProgressHUD.show(nil, interaction: false)
                let input = UpdateMaterielInput()
                input.id = data.id
                input.name = data.name
                input.unit = data.unit
                input.type = 0
                input.remark = data.remark
                let error = MaterielService(bodyParameter: input, delegate: self, sender: indexPath).updateMateriel()
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription, interaction: false)
                }
                completionHandler(true)
            }
            invalidAction.backgroundColor = UIColor(named: "materielGreen")
        default:
            break
        }
        
        let editAction = UIContextualAction(style: .normal, title: "编辑") { action, sourceView, completionHandler in
            self.performSegue(withIdentifier: "toEditView", sender: [self.materielsData[indexPath.row], indexPath])
            completionHandler(true)
        }
        
        
        return UISwipeActionsConfiguration(actions: [editAction, invalidAction])
    }
}

extension MaterielViewController: MaterielTableViewCellDelegate {
    func outputOrInput(actionType: Int, indexPath: IndexPath) {
        performSegue(withIdentifier: "toMaterielActionView", sender: [actionType, indexPath])
    }
}

protocol MaterielTableViewCellDelegate: AnyObject{
    func outputOrInput(actionType:Int, indexPath:IndexPath) -> Void
}

class MaterielTableViewCell: UITableViewCell {
    
    @IBOutlet weak var outputButton: DesignableButton!
    @IBOutlet weak var inputButton: DesignableButton!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate:MaterielTableViewCellDelegate?
    var indexPath:IndexPath?
    
    @IBAction func buttonPressed(_ sender: DesignableButton) {
        if delegate != nil {
            var actionType = 0;
            switch sender {
            case inputButton:
                actionType = 0
            case outputButton:
                actionType = 1
            default:
                break
            }
            delegate?.outputOrInput(actionType: actionType, indexPath: indexPath!)
        }
    }
    
}
