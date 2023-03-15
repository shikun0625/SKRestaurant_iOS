//
//  MealsViewControllers.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/14/R5.
//

import Foundation
import UIKit
import ProgressHUD
import MJRefresh

class MealsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var mealses:[Meals] = []
    private var mealsesData:[Int:[Meals]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let header = MJRefreshNormalHeader { [unowned self] in
            self.getMeals()
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(mealsAdded), name: .SKMealsAddedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mealsUpdated), name: .SKMealsUpdatedNotificationName, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .SKMealsAddedNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SKMealsUpdatedNotificationName, object: nil)
    }
    
    @objc func mealsAdded(notification:Notification) -> Void{
        mealses.append(notification.object as! Meals)
        prepareData()
        tableView.reloadData()
    }
    
    @objc func mealsUpdated(notification:Notification) -> Void{
        let object:[Any] = notification.object as! [Any]
        let indexPath:IndexPath = object[1] as! IndexPath
        let meals:Meals = object[0] as! Meals
        mealses[mealses.firstIndex(where: { Meals in
            return meals.id == Meals.id
        })!] = meals;
        prepareData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func getMeals() -> Void {
        let error = MealsService(delegate: self).getMealses()
        if error != nil {
            tableView.mj_header?.endRefreshing()
        }
    }
    
    private func prepareData() -> Void {
        let sortedData = mealses.sorted { m1, m2 in
            if m1.type == m2.type {
                if m1.status! == m2.status! {
                    return m1.createTime! > m2.createTime!
                } else {
                    return m1.status! < m2.status!
                }
            } else {
                return m1.type! < m2.type!
            }
        }
        mealsesData = [:]
        for meals in sortedData {
            if !mealsesData.keys.contains(meals.type!) {
                mealsesData[meals.type!] = []
            }
            mealsesData[meals.type!]?.append(meals)
        }
    }
}

extension MealsViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .GetMealses {
                tableView.mj_header?.endRefreshing()
                let result = output as! GetMealsesOutput
                mealses = result.resp.mealses
                prepareData()
                tableView.reloadData()
            } else if service == .UpdateMeals {
                let result = output as! UpdateMealsOutput
                let orgIndexPath = sender as! IndexPath
                let index = mealses.firstIndex { Meals in
                    return Meals.id == result.resp.id
                }
                mealses[index!] = result.resp
                prepareData()
                var newIndexPath:IndexPath?
                let keys = mealsesData.keys.sorted()
                for section in 0..<keys.count {
                    var found = false
                    let values = mealsesData[keys[section]];
                    for row in 0..<values!.count {
                        let value = values![row]
                        if value.id == result.resp.id {
                            newIndexPath = IndexPath(row: row, section: section)
                            found = true
                            break
                        }
                    }
                    if found {
                        break
                    }
                }
                tableView.moveRow(at: orgIndexPath, to: newIndexPath!)
                tableView.reloadRows(at: [newIndexPath!], with: .automatic)
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}

extension MealsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealsesData.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = Array(mealsesData.keys).sorted()
        return mealsesData[keys[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MealsTableViewCell
        let keys = Array(mealsesData.keys).sorted()
        let meals = mealsesData[keys[indexPath.section]]![indexPath.row]
        cell.nameLabel.text = meals.name
        cell.valueLabel.text = String(format: "%.2f", meals.value!)
        cell.statusLabel.text = convertMealsStatusToString(status: meals.status!)
        switch meals.status! {
        case 0:
            cell.statusLabel.textColor = UIColor(named: "mealsBlue")
            cell.editStatusButton.backgroundColor = .systemRed
            cell.editStatusButton.setTitle("下架", for: .normal)
            cell.editValueButton.isEnabled = true
            cell.editValueButton.backgroundColor = UIColor(named: "mealsBlue")
        case 1:
            cell.statusLabel.textColor = .systemGray3
            cell.editStatusButton.backgroundColor = UIColor(named: "mealsBlue")
            cell.editStatusButton.setTitle("上架", for: .normal)
            cell.editValueButton.isEnabled = false
            cell.editValueButton.backgroundColor = .systemGray6
        default:
            break
        }
        
        
        cell.remarkLabel.text = meals.remark
        var materielStr = ""
        for materiel in meals.materiels! {
            materielStr.append(materiel.name!)
            materielStr.append("，")
        }
        materielStr.removeLast()
        cell.materielsLabel.text = materielStr
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = Array(mealsesData.keys).sorted()
        return convertMealsTypeToString(type: keys[section])
    }
}

extension MealsViewController: MealsTableViewCellDelegate {
    func editStatusPressed(indexPath: IndexPath) {
        ProgressHUD.show(nil, interaction: false)
        let keys = Array(mealsesData.keys).sorted()
        let meals = mealsesData[keys[indexPath.section]]![indexPath.row]
        let input = UpdateMealsInput()
        input.status = meals.status == 0 ? 1 : 0
        input.value = meals.value
        input.id = meals.id
        let error = MealsService(bodyParameter: input, delegate: self, sender: indexPath).updateMeals()
        if error != nil {
            tableView.mj_header?.endRefreshing()
        }
    }
    
    func editValuePressed(indexPath: IndexPath) {
        let alertController = UIAlertController(title: "修改价格", message: "输入新价格", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [unowned self] action in
            let textField = alertController.textFields?.first
            let value = Float(textField!.text!)
            if value != nil {
                ProgressHUD.show(nil, interaction: false)
                let keys = Array(self.mealsesData.keys).sorted()
                let meals = self.mealsesData[keys[indexPath.section]]![indexPath.row]
                let input = UpdateMealsInput()
                input.status = meals.status
                input.value = value
                input.id = meals.id
                let error = MealsService(bodyParameter: input, delegate: self, sender: indexPath).updateMeals()
                if error != nil {
                    tableView.mj_header?.endRefreshing()
                }
                return
            }
            let alert = UIAlertController(title: "错误", message: "新价格只能是数字", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(alert, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        alertController.addTextField { [unowned self] textField in
            let keys = Array(self.mealsesData.keys).sorted()
            let meals = self.mealsesData[keys[indexPath.section]]![indexPath.row]
            textField.keyboardType = .decimalPad
            textField.text = String(meals.value!)
            textField.clearsOnBeginEditing = true
        }
        present(alertController, animated: true)
    }
}

//MARK: - MealsTableViewCell

protocol MealsTableViewCellDelegate: AnyObject {
    func editStatusPressed(indexPath:IndexPath) -> Void
    func editValuePressed(indexPath:IndexPath) -> Void
}

class MealsTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var materielsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    weak var delegate:MealsTableViewCellDelegate?
    var indexPath:IndexPath?
    
    @IBOutlet weak var editStatusButton: DesignableButton!
    @IBOutlet weak var editValueButton: DesignableButton!
    
    @IBAction func editValuePressed(_ sender: DesignableButton) {
        if delegate != nil {
            delegate?.editValuePressed(indexPath: indexPath!)
        }
    }
    
    @IBAction func editStatusPressed(_ sender: DesignableButton) {
        if delegate != nil {
            delegate?.editStatusPressed(indexPath: indexPath!)
        }
    }
}

