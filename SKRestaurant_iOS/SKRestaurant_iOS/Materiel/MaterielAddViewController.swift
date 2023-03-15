//
//  MaterielAddViewController.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import UIKit
import ProgressHUD
import IQKeyboardManagerSwift

//MARK: - MaterielAddViewController
class MaterielAddViewController: UIViewController {
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    private var selectedUnit:Int?
    private var selectedType:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitButton.menu = {
            var actions:[UIAction] = []
            for i in 0...8 {
                let action = UIAction(title: convertUnitToString(unit: i), handler: { [unowned self] action in
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
                let action = UIAction(title: convertMaterielTypeToString(type: i), handler: { [unowned self] action in
                    self.typeButton.setTitle(action.title, for: .normal)
                    self.selectedType = i
                })
                actions.append(action)
            }
            
            return UIMenu(children: actions)
            
        }()
    }
    
    @IBAction func conformPressed(_ sender: UIButton) {
        IQKeyboardManager.shared.resignFirstResponder()
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
        let error = MaterielService(bodyParameter: input, delegate: self).createMateriel()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription, interaction: false)
        }
    }
}

extension MaterielAddViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .CreateMateriel {
                dismiss(animated: true) {
                    let resp = (output as! CreateMaterielOutput).resp
                    NotificationCenter.default.post(Notification(name: .SKMaterielAddedNotificationName, object: resp))
                }
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}
