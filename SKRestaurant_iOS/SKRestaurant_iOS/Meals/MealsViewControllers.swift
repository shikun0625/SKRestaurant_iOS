//
//  MealsViewControllers.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/14/R5.
//

import Foundation
import UIKit
import ProgressHUD

//MARK: - MealsViewController
class MealsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - MealsTableViewCell
class MealsTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var materielsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}


//MARK: - MealsAddViewController
class MealsAddViewController: UIViewController {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    
    var materiels:[Materiel] = []
    var checkedMateriels:[Materiel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ProgressHUD.show(nil, interaction: false)
        let input = GetMaterielInput()
        input.type = 0
        let error = MaterielService(queryParameter: input, delegate: self).getMateriels()
        if error != nil {
            dismiss(animated: true)
        }
    }
    
    
    @IBAction func conformPressed(_ sender: UIButton) {
        errorMessageLabel.text = ""
        if nameTextField.text?.count == 0 {
            errorMessageLabel.text = "请输入品名"
            return
        }
        let value = Float(valueTextField.text!)
        if value == nil {
            errorMessageLabel.text = "单价只能为数字"
            return
        }
        
        if checkedMateriels.count == 0 {
            errorMessageLabel.text = "至少关联一项物料"
            return
        }
        ProgressHUD.show("", interaction: false)
        let input = CreateMealsInput()
        input.value = value
        input.name = nameTextField.text
        input.remark = remarkTextField.text
        input.status = 0
        input.materielIds = []
        for materiel in checkedMateriels {
            input.materielIds?.append(materiel.id!)
        }
        let error = MealsService(bodyParameter: input, delegate: self).createMeals()
        if error != nil {
            ProgressHUD.showFailed(error?.localizedDescription, interaction: false)
        }
    }
}

extension MealsAddViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .GetMateriels {
                let resp = (output as! GetMaterielOutput).resp
                materiels = resp.materiels
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
                collectionHeight.constant = collectionView.contentSize.height
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.view.layoutIfNeeded()
                }
            } else if service == .CreateMeals {
                let resp = (output as! CreateMealsOutput).resp
                dismiss(animated: true) {
                    
                }
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}

extension MealsAddViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return materiels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let materiel = materiels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MealsAddCollectionViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        cell.checkButton.setTitle(materiel.name, for: .normal)
        cell.checkButton.isSelected = checkedMateriels.contains(where: { Materiel in
            return materiel.id == Materiel.id
        })
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
}

extension MealsAddViewController: MealsAddCollectionViewCellDelegate {
    func checkChanged(checked: Bool, indexPath: IndexPath) {
        let materiel = materiels[indexPath.row]
        var index = checkedMateriels.firstIndex { Materiel in
            return materiel.id == Materiel.id
        }
        if checked {
            if index == nil {
                checkedMateriels.append(materiel)
            }
        } else {
            if index != nil {
                checkedMateriels.remove(at: index!)
            }
        }
    }
    
    
}


//MARK: - MealsAddCollectionViewCell
protocol MealsAddCollectionViewCellDelegate: AnyObject {
    func checkChanged(checked:Bool, indexPath:IndexPath) -> Void
}

class MealsAddCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var checkButton: UIButton!
    
    weak var delegate: MealsAddCollectionViewCellDelegate?
    var indexPath:IndexPath?
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if delegate != nil {
            delegate!.checkChanged(checked: sender.isSelected, indexPath: indexPath!)
        }
    }
    
}
