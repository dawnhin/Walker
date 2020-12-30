//
//  WeeklyQuantitySampleTableViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 11/12/2020.
//

import UIKit
import HealthKit

class WeeklyQuantitySampleTableViewController: HealthDataTableViewController, HealthQueryDataSource {

    let calendar: Calendar = .current
    let healthStore=HealthData.healthStore
    var quantityTypeIdentifier: HKQuantityTypeIdentifier {
        return HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)
    }
    var quantityType: HKQuantityType {
        return HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier)!
    }
    var query: HKStatisticsCollectionQuery?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if query != nil {
            return
        }
        //请求授权
        let dataTypeValues: Set=Set([quantityType])
        print("请求HealthKit授权")
        self.healthStore.requestAuthorization(toShare: dataTypeValues, read: dataTypeValues) { (success, error) in
            if success{
                self.calculateDailyQuantitySamplesForPastWeek()
            }
        }
    }
    func calculateDailyQuantitySamplesForPastWeek() {
        performQuery {
            DispatchQueue.main.async {[weak self] in
                self?.reloadData()
            }
        }
    }
    //MARK: - 健康查询数据源
    func performQuery(completion: @escaping() -> Void) {
        let predicate=createLastWeekPredicate()
        let anchorDate=createAnchorDate()
        let dailyIntervald=DateComponents(day: 1)
        let statisticsOptions=getStatisticsOptions(for: dataTypeIdentifier)
        let query=HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: statisticsOptions, anchorDate: anchorDate, intervalComponents: dailyIntervald)
        //用于HKStatisticsCollection对象处理者block
        let updateInterfaceWithStatistics: (HKStatisticsCollection) -> Void = {statistics in
            self.dataValues=[]
            let now=Date()
            let startDate=getLastWeekStartDate()
            let endDate=now
            statistics.enumerateStatistics(from: startDate, to: endDate) {[weak self] (statistics, stop) in
                var dataValue=HealthDataTypeValue(startDate: statistics.startDate, endDate: statistics.endDate, value: 0)
                if let quantity=getStatisticsQuantity(for: statistics, with: statisticsOptions),
                   let identifier=self?.dataTypeIdentifier,
                   let unit=preferredUnit(for: identifier){
                    dataValue.value=quantity.doubleValue(for: unit)
                }
                self?.dataValues.append(dataValue)
            }
            completion()
        }
        query.initialResultsHandler={query, statisticsCollection, error in
            if let statisticsCollection = statisticsCollection {
                updateInterfaceWithStatistics(statisticsCollection)
            }
        }
        query.statisticsUpdateHandler={[weak self] query, statistics, statisticsCollection, error in
            //如果可视数据类型更新确保我们仅更新界面
            if let statisticsCollection = statisticsCollection, query.objectType?.identifier == self?.dataTypeIdentifier {
                updateInterfaceWithStatistics(statisticsCollection)
            }
        }
        self.healthStore.execute(query)
        self.query=query
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let query = query {
            self.healthStore.stop(query)
        }
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
