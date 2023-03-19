//
//  MaterielActionViewController.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import UIKit
import ProgressHUD
import IQKeyboardManagerSwift

class MaterielActionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var reasonButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    var actionType:Int = 0
    var selectedReason:Int?
    var materiel:Materiel?
    var indexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reasonButton.menu = {
            var actions:[UIAction] = []
            let count = actionType == 0 ? 3 : 2
            for index in 0...count {
                let action = UIAction(title: convertMaterielActionReasonToString(actionType: actionType, reason: index), handler: { [unowned self] action in
                    self.reasonButton.setTitle(action.title, for: .normal)
                    self.selectedReason = index
                })
                actions.append(action)
            }
            return UIMenu(children: actions)
        }()
        
        switch actionType {
        case 0:
            titleLabel.text = "\(materiel?.name ?? "") 入库"
        case 1:
            titleLabel.text = "\(materiel?.name ?? "") 出库"
        default:
            break
        }
    }
    @IBAction func conformPressed(_ sender: UIButton) {
        IQKeyboardManager.shared.resignFirstResponder()
        errorMessageLabel.text = ""
        if selectedReason == nil {
            errorMessageLabel.text = "请选择原因"
            return
        }
        
        let count = Int(countTextField.text!)
        if count == nil {
            errorMessageLabel.text = "数量只能为整数"
            return
        }
        ProgressHUD.show(nil, interaction: false)
        let input = CreateMaterielActionInput()
        input.materielId = materiel!.id
        input.delta = actionType == 0 ? count : -count!
        input.reason = selectedReason
        input.actionType = actionType
        let error = MaterielActionService(bodyParameter: input, delegate: self).createMaterielAction()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription, interaction: false)
        }
    }
    
}

extension MaterielActionViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .CreateMaterielAction {
                dismiss(animated: true) {
                    let resp = (output as! CreateMaterielActionOutput).resp
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

