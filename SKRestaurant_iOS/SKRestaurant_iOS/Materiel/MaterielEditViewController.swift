//
//  MaterielEditViewController.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import UIKit
import ProgressHUD
import IQKeyboardManagerSwift

class MaterielEditViewController: UIViewController {
    
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitButton: UIButton!
    
    var materielInfo: Materiel?
    var indexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = materielInfo?.name
        remarkTextField.text = materielInfo?.remark
        unitButton.menu = {
            var actions:[UIAction] = []
            
            for i in 0...8 {
                let action = UIAction(title: convertUnitToString(unit: i), handler: { [unowned self] action in
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
        IQKeyboardManager.shared.resignFirstResponder()
        ProgressHUD.show(nil, interaction: false)
        let input = UpdateMaterielInput()
        input.id = materielInfo?.id
        input.name = nameLabel.text
        input.unit = materielInfo?.unit
        input.type = materielInfo?.type
        input.remark = remarkTextField.text
        let error = MaterielService(bodyParameter: input, delegate: self).updateMateriel()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription, interaction: false)
        }
    }
}

extension MaterielEditViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .CreateMaterielAction {
                dismiss(animated: true) {
                    let resp = (output as! UpdateMaterielOutput).resp
                    NotificationCenter.default.post(Notification(name: .SKMaterielUpdatedNotificationName, object: [resp, self.indexPath as Any]))
                }
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}
