//
//  HealthDataTableViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 4/12/2020.
//

import UIKit
import HealthKit
protocol HealthDataTableViewControllerDelegate: class {
    func didAddNewData(with value: Double)
}
///一个允许在健康数据类型作为数据源和手动添加新样本切换视图器
class HealthDataTableViewController: DataTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem()
    }
    override func setUpNavigationController() {
        super.setUpNavigationController()
        //数据类型选择("更多")工具条按钮
        let leftBarButtonItem=UIBarButtonItem(title: "更多", style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapLeftBarButtonItem))
        navigationItem.leftBarButtonItem=leftBarButtonItem
        let rightBarButtonItem=UIBarButtonItem(title: "添加", style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapRightBarButtonItem))
        navigationItem.rightBarButtonItem=rightBarButtonItem
    }
    func updateNavigationItem() {
        navigationItem.title=getDataTypeName(for: dataTypeIdentifier)
    }
    // MARK: - 按钮选择器
    @objc private func didTapLeftBarButtonItem(){
        presentDataTypeSelectionView()
    }
    @objc private func didTapRightBarButtonItem(){
        presentManualEntryViewController()
    }
    // MARK: - 其它/数据类型选择
    private func presentDataTypeSelectionView(){
        let title="选择健康数据类型"
        let alertController=UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for dataType in HealthData.readDataTypes {
            let actionTitle=getDataTypeName(for: dataType.identifier)
            let action=UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default) {[weak self] (action) in
                self?.didSelectDataTypeIdentifier(dataType.identifier)
            }
            alertController.addAction(action)
        }
        let cancel=UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    private func didSelectDataTypeIdentifier(_ dataTypeIdentifier: String){
        self.dataTypeIdentifier=dataTypeIdentifier
        HealthData.requestHealthDataAccessIfNeeded(dataTypes: [dataTypeIdentifier]) { [weak self](success) in
            self?.updateNavigationItem()
        }
        if let healthQueryDataSourceProvider = self as? HealthQueryDataSource {
            healthQueryDataSourceProvider.performQuery { [weak self] in
                DispatchQueue.main.async {
                    self?.reloadData()
                }
            }
        }else{
            DispatchQueue.main.async {[weak self] in
                self?.reloadData()
            }
        }
    }
    // MARK: - 添加数据
    private func presentManualEntryViewController(){
        let title=getDataTypeName(for: dataTypeIdentifier)
        let message="输入一个值添加一个样本到你的健康数据"
        let alertController=UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField) in
            textField.placeholder=title
        }
        let cancelAction=UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel)
        alertController.addAction(cancelAction)
        let confirmAction=UIAlertAction(title: "添加", style: UIAlertAction.Style.default) { [weak self,weak alertController] _ in
            guard let alertController=alertController, let textField=alertController.textFields?.first else {
                return
            }
            if let string=textField.text, let doubleValue=Double(string){
                self?.didAddNewData(with: doubleValue)
            }
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HealthDataTableViewController: HealthDataTableViewControllerDelegate{
    ///处理一个到来HealthKit健康数据对应值
    func didAddNewData(with value: Double) {
        guard let sample = processHealthSample(with: value) else { return }
        HealthData.saveHealthData([sample]) {[weak self] (success, error) in
            if let error=error{
                print("DataTypeTableViewController添加新数据错误:", error.localizedDescription)
            }
            if success{
                print("成功保存一个新样本",sample)
                DispatchQueue.main.async {
                    self?.reloadData()
                }
            }else{
                print("错误:不能保存新样本",sample)
            }
        }
    }
    private func processHealthSample(with value: Double) -> HKObject?{
//        let dataTypeIdentifier=self.dataTypeIdentifier
        guard
            let sampleType = getSampleType(for: dataTypeIdentifier),
            let unit = preferredUnit(for: dataTypeIdentifier)
        else { return nil }
        let now=Date()
        let start=now
        let end=now
        var optionalSample: HKObject?
        if let quantityType = sampleType as? HKQuantityType {
            let quantity=HKQuantity(unit: unit, doubleValue: value)
            let quantitySample=HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)
            optionalSample=quantitySample
        }
        if let categoryType = sampleType as? HKCategoryType {
            let categorySample=HKCategorySample(type: categoryType, value: Int(value), start: start, end: end)
            optionalSample=categorySample
        }
        return optionalSample
    }
}
