//
//  OrderViewControllers.swift
//  SKRestaurant_iOS
//
//  Created by 强尼 on 3/15/R5.
//

import Foundation
import UIKit
import ProgressHUD

class OrderViewController: UIViewController {
    private var menus:[Menu] = []
    private var menusData:[Int:[Menu]] = [:]
    private var selectedTypeIndex = 0
    
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadData()
        }
    }
    
    private func loadData() -> Void {
        ProgressHUD.show(nil, interaction: false)
        let error = MenuService(delegate: self).getMenu()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription)
        }
    }
    
    private func prepareData() -> Void {
        let sortedData = menus.sorted { m1, m2 in
            if m1.type == m2.type {
                return m1.name! > m2.name!
            } else {
                return m1.type! < m2.type!
            }
        }
        menusData = [:]
        for menu in sortedData {
            if !menusData.keys.contains(menu.type!) {
                menusData[menu.type!] = []
            }
            menusData[menu.type!]?.append(menu)
        }
    }
}

extension OrderViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .GetMenu {
                let resultOutput = output as! GetMenuOutput
                menus = resultOutput.resp.mealses
                prepareData()
                topCollectionView.reloadData()
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}

extension OrderViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case topCollectionView:
            return menusData.keys.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let keys = menusData.keys.sorted()
        switch collectionView {
        case topCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrderViewTopCollectionCell
            cell.titleLabel.text = convertMealsTypeToString(type: keys[indexPath.row])
            if selectedTypeIndex == indexPath.row {
                cell.backgroundColor = .white
            } else {
                cell.backgroundColor = .systemGray4
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case topCollectionView:
            return CGSize(width: 120, height: 120)
        default:
            return CGSizeZero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case topCollectionView:
            selectedTypeIndex = indexPath.row
            topCollectionView.reloadData()
        default:
            break
        }
    }
}


class OrderViewTopCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
}
