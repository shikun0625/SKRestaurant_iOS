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
    private var materiels:[Materiel] = []
    private var menusData:[Int:[Menu]] = [:]
    private var selectedTypeIndex = 0
    private var selectedMenuList:[String:Int] = [:]
    
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var orderListTable: UITableView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var takeawayButton: UIButton!
    @IBOutlet weak var orderButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        orderListTable.delegate = self
        orderListTable.dataSource = self
        
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
    
    private func getMenuAvailable(menu:Menu) -> Int {
        var minCount = 9999999
        for materielId in menu.materielIds {
            let materiel = materiels.first { Materiel in
                return Materiel.id == materielId
            }
            minCount = min(minCount, materiel!.count!)
        }
        return minCount
    }
    
    private func changeMenuAvailable(menu:Menu, delta:Int) -> Void {
        for materielId in menu.materielIds {
            let materiel = materiels.first { Materiel in
                return Materiel.id == materielId
            }
            materiel!.count = materiel!.count! + delta
        }
    }
    
    private func calculateTotalAmount() -> Void{
        var amount:Float = 0.0
        let keys = Array(selectedMenuList.keys)
        for key in keys {
            let menu = menus.first { Menu in
                return Menu.id == Int(key)
            }
            let count = selectedMenuList[key]
            amount = amount + menu!.value! * Float(count!)
        }
        totalAmount.text = String(format: "%.2f", amount)
    }
    
    private func reloadViews() -> Void {
        orderListTable.reloadData()
        topCollectionView.reloadData()
        mainCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WaitingForPayViewController {
            let vc = segue.destination as! WaitingForPayViewController
            vc.isModalInPresentation = true
            vc.orderId = (sender as! String)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton?) {
        selectedMenuList = [:]
        selectedTypeIndex = 0
        loadData()
        orderListTable.reloadData()
        calculateTotalAmount()
        orderButton.isEnabled = false
        orderButton.backgroundColor = .systemGray5
    }
    
    @IBAction func orderPressed(_ sender: DesignableButton) {
        ProgressHUD.show(nil, interaction: false)
        let input = CreateOrderInput()
        input.totalAmount = Float(totalAmount.text!)
        input.menus = selectedMenuList
        input.type = takeawayButton.isSelected ? 1 : 0
        let error = OrderService(bodyParameter: input, delegate: self).order()
        if error != nil {
            ProgressHUD.showError(error?.localizedDescription, interaction: false)
        }
    }
    @IBAction func takeawayPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

extension OrderViewController: HttpServiceDelegate {
    func requestCompleted(service: SKHTTPService, result: SKHttpRequestResult, output: Any?, error: Error?, sender: Any?) {
        switch result {
        case .success:
            ProgressHUD.dismiss()
            if service == .GetMenu {
                let resultOutput = output as! GetMenuOutput
                menus = resultOutput.resp.menus
                materiels = resultOutput.resp.materiels
                prepareData()
                reloadViews()
            } else if service == .PostOrder {
                cancelPressed(nil)
                let resultOutput = output as! CreateOrderOutput
                if resultOutput.resp.status == 0 && resultOutput.resp.payType == nil {
                    performSegue(withIdentifier: "toWaitingForPay", sender: resultOutput.resp.orderId)
                }
            }
        case .failure:
            ProgressHUD.showFailed(output == nil ? error?.localizedDescription : (output as! HttpServiceOutput).errorMessage, interaction: false)
        default:
            ProgressHUD.dismiss()
        }
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMenuList.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderViewListTableViewCell
        let menuId = Array(selectedMenuList.keys).sorted()[indexPath.row]
        let menu = menus.first { menu in
            return menu.id == Int(menuId)
        }
        cell.titleLabel.text = menu?.name
        cell.countLabel.text = "×\(String(selectedMenuList[menuId]!))"
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension OrderViewController: OrderViewListTableViewCellDelegate {
    func deletePressed(indexPath: IndexPath) {
        let menuId = Array(selectedMenuList.keys).sorted()[indexPath.row]
        let value = selectedMenuList[menuId]! - 1
        selectedMenuList[menuId] = value
        if value == 0 {
            selectedMenuList.removeValue(forKey: menuId)
        }
        calculateTotalAmount()
        
        if selectedMenuList.keys.count == 0 {
            orderButton.isEnabled = false
            orderButton.backgroundColor = .systemGray5
        } else {
            orderButton.isEnabled = true
            orderButton.backgroundColor = UIColor(named: "orderBlue")
        }
        
        let menu = menus.first { Menu in
            return Menu.id == Int(menuId)
        }
        changeMenuAvailable(menu: menu!, delta: 1)
        reloadViews()
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
        case mainCollectionView:
            let keys = Array(menusData.keys).sorted()
            if keys.count == 0 {
                return 0
            }
            return menusData[keys[selectedTypeIndex]]!.count
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
        case mainCollectionView:
            let menu = menusData[keys[selectedTypeIndex]]![indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrderViewMainCollectionCell
            cell.titleLabel.text = menu.name
            cell.valueLabel.text = String(format: "%.2f", menu.value!)
            let minCount = getMenuAvailable(menu: menu)
            cell.availableCountLabel.text = String(format: "余：%d", minCount)
            cell.setEnable(enable: minCount > 0)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case topCollectionView:
            return CGSize(width: 120, height: 80)
        case mainCollectionView:
            switch SCREEN_WIDTH {
            case 1180:
                return CGSize(width: 223, height: 223)
            case 1194:
                return CGSize(width: 227, height: 227)
            case 1366:
                return CGSize(width: 213, height: 213)
            case 1133:
                return CGSize(width: 207, height: 207)
            case 1024:
                return CGSize(width: 171, height: 171)
            default:
                return CGSize(width: 170, height: 170)
            }
        default:
            return CGSizeZero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case topCollectionView:
            selectedTypeIndex = indexPath.row
            topCollectionView.reloadData()
            mainCollectionView.reloadData()
        case mainCollectionView:
            let menusDataKeys = menusData.keys.sorted()
            let menu = menusData[menusDataKeys[selectedTypeIndex]]![indexPath.row]
            if getMenuAvailable(menu: menu) == 0 {
                return
            }
            let menuId = String(menu.id!)
            if selectedMenuList.keys.contains(menuId) {
                var value = selectedMenuList[menuId]
                value = value! + 1
                selectedMenuList[menuId] = value
            } else {
                selectedMenuList[menuId] = 1
            }
            calculateTotalAmount()
            
            if selectedMenuList.keys.count == 0 {
                orderButton.isEnabled = false
                orderButton.backgroundColor = .systemGray5
            } else {
                orderButton.isEnabled = true
                orderButton.backgroundColor = UIColor(named: "orderBlue")
            }
            
            changeMenuAvailable(menu: menu, delta: -1)
            reloadViews()
        default:
            break
        }
    }
}

class OrderViewTopCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class OrderViewMainCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var availableCountLabel: UILabel!
    @IBOutlet weak var frameView: DesignableView!
    
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet weak var valueWidth: NSLayoutConstraint!
    @IBOutlet weak var availableCountWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switch SCREEN_WIDTH {
        case 1180:
            titleWidth.constant = 223 - 30 - 40
            valueWidth.constant = 223 - 30 - 40
            availableCountWidth.constant = 223 - 30 - 40
        case 1194:
            titleWidth.constant = 227 - 30 - 40
            valueWidth.constant = 227 - 30 - 40
            availableCountWidth.constant = 227 - 30 - 40
        case 1366:
            titleWidth.constant = 213 - 30 - 40
            valueWidth.constant = 213 - 30 - 40
            availableCountWidth.constant = 213 - 30 - 40
        case 1133:
            titleWidth.constant = 207 - 30 - 40
            valueWidth.constant = 207 - 30 - 40
            availableCountWidth.constant = 207 - 30 - 40
        case 1024:
            titleWidth.constant = 171 - 30 - 40
            valueWidth.constant = 171 - 30 - 40
            availableCountWidth.constant = 171 - 30 - 40
        default:
            titleWidth.constant = 170 - 30 - 40
            valueWidth.constant = 170 - 30 - 40
            availableCountWidth.constant = 170 - 30 - 40
        }
    }
    
    func setEnable(enable:Bool) -> Void {
        if enable {
            frameView.backgroundColor = .white
            titleLabel.textColor = .label
            valueLabel.textColor = .label
            availableCountLabel.textColor = .label
        } else {
            frameView.backgroundColor = .systemGray6
            titleLabel.textColor = .systemGray
            valueLabel.textColor = .systemGray4
            availableCountLabel.textColor = .systemGray4
        }
    }
}

protocol OrderViewListTableViewCellDelegate: AnyObject {
    func deletePressed(indexPath: IndexPath) -> Void
}

class OrderViewListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    var indexPath: IndexPath?
    weak var delegate: OrderViewListTableViewCellDelegate?
    
    @IBAction func deletePressed(_ sender: UIButton) {
        if delegate != nil {
            delegate?.deletePressed(indexPath: indexPath!)
        }
    }
}
