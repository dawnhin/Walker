//
//  HealthQueryTableViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 27/12/2020.
//

import UIKit
import HealthKit
import CareKitUI

class HealthQueryTableViewController: ChartTableViewController, HealthQueryDataSource {

    var queryPredicate: NSPredicate?
    var queryAnchor: HKQueryAnchor?
    var queryLimit=HKObjectQueryNoLimit
    //MARK:- 视图生命周期重载
    override func setUpViewController() {
        super.setUpViewController()
        setUpFetchButton()
        setUpRefreshControl()
    }
    private func setUpFetchButton(){
        let barButtonItem=UIBarButtonItem(title: "获取", style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapFetchButton))
        navigationItem.rightBarButtonItem=barButtonItem
    }
    private func setUpRefreshControl(){
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: UIControl.Event.valueChanged)
        self.refreshControl=refreshControl
    }
    //MARK: - Selectors
    @objc func didTapFetchButton(){
        fetchNetworkData()
    }
    @objc func refreshControlValueChanged(){
        loadData()
    }
    func fetchNetworkData() {
        Network.pull { [weak self] (serverResponse) in
            self?.handleServerResponse(serverResponse)
        }
    }
    ///处理从远程伺服器发送响应
    func handleServerResponse(_ serverResponse: ServerResponse) {
        loadData()
    }
    //MARK: - HealthQueryDataSource
    ///实现查询和重新加载数据直到完成
    func loadData() {
        performQuery {
            DispatchQueue.main.async {[weak self] in
                self?.reloadData()
            }
        }
    }
    func performQuery(completion: @escaping () -> Void) {
        guard let sampleType = getSampleType(for: dataTypeIdentifier) else { return }
        let anchoredObjectQuery=HKAnchoredObjectQuery(type: sampleType, predicate: queryPredicate, anchor: queryAnchor, limit: queryLimit) { (query, samplesOrNil, deletedObjectsOrNil, anchor, errorOrNil) in
            guard let samples=samplesOrNil else { return }
            self.dataValues=samples.map({ (sample) -> HealthDataTypeValue in
                var dataValue=HealthDataTypeValue(startDate: sample.startDate, endDate: sample.endDate, value: .zero)
                if let quantitySample=sample as? HKQuantitySample, let unit=preferredUnit(for: quantitySample){
                    dataValue.value=quantitySample.quantity.doubleValue(for: unit)
                }
                return dataValue
            })
            completion()
        }
        HealthData.healthStore.execute(anchoredObjectQuery)
    }
    ///在重新加载`tableView`数据之前重载'reloadData'更新`chartView`
    override func reloadData() {
        DispatchQueue.main.async {
            self.chartView.applyDefaultConfiguration()
            let dateLastUpdate=Date()
            self.chartView.headerView.detailLabel.text=createChartDateLastUpdatedLabel(dateLastUpdate)
            self.chartView.headerView.titleLabel.text=getDataTypeName(for: self.dataTypeIdentifier)
            self.dataValues.sort {
                $0.startDate<$1.startDate
            }
            let sampleStartDates=self.dataValues.map {
                $0.startDate
            }
            self.chartView.graphView.horizontalAxisMarkers=createHorizontalAxisMarkers(for: sampleStartDates)
            let dataSeries=self.dataValues.compactMap {
                CGFloat($0.value)
            }
            guard let unit=preferredUnit(for: self.dataTypeIdentifier),
                  let unitTitle=getUnitDescription(for: unit)
            else{
                return
            }
            self.chartView.graphView.dataSeries=[
                OCKDataSeries(values: dataSeries, title: unitTitle)
            ]
            self.view.layoutIfNeeded()
            super.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
