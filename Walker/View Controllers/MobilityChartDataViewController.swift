//
//  MobilityChartDataViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 26/12/2020.
//

import UIKit
import HealthKit
///移动相关健康数据
class MobilityChartDataViewController: DataTypeCollectionViewController {

    let calendar: Calendar=Calendar.current
    var mobilityContent: [String] = [
        HKQuantityTypeIdentifier.stepCount.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue
    ]
    var queries: [HKAnchoredObjectQuery] = []
    //MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        data=mobilityContent.map{
            ($0, [])
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //授权
        if !queries.isEmpty {
            return
        }
        HealthData.requestHealthDataAccessIfNeeded(dataTypes: mobilityContent) { (success) in
            if success{
                if success {
                    self.setUpBackgroudObservers()
                    self.loadData()
                }
            }
        }
    }

    //MARK: - 数据方法
    func loadData() {
        performQuery {
            //UI更新放在主线程
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    func setUpBackgroudObservers() {
        data.compactMap {
            getSampleType(for: $0.dataTypeIdentifier)
        }.forEach { (sampleType) in
            createAnchoredObjectQuery(for: sampleType)
        }
    }
    func createAnchoredObjectQuery(for sampleType: HKSampleType) {
        //自定义请求参数
        let predicate=createLastWeekPredicate()
        let limit=HKObjectQueryNoLimit
        //在内存中获取持久锚点
        let anchor=HealthData.getAnchor(for: sampleType)
        //创建HKAnchoredObjecyQuery
        let query=HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: limit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            //错误处理
            if let error=errorOrNil{
                print("HKAnchoredObjectQuery带标识符:\(sampleType.identifier)initialResultsHandler出现错误:\(error.localizedDescription)")
                return
            }
            print("HKAnchoredObjectQuery initialResultsHandler返回:\(sampleType.identifier)!")
            //用样本类型更新锚点
            HealthData.updateAnchor(newAnchor, from: query)
            //结果返回匿名后台队列
            Network.push(addedSamples: samplesOrNil, deletedSamples: deletedObjectsOrNil)
        }
        //创建更新处理者用于长期后台查询
        query.updateHandler={ (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            //处理错误
            if let error = errorOrNil {
                print("带标识符\(sampleType.identifier)HKAnchoredObjectQuery initialResultsHandler错误:\(error.localizedDescription)")
                return
            }
            print("HKAnchoredObjectQuery initialResultsHandler返回\(sampleType.identifier)!")
            //对于样本类型更新锚点
            HealthData.updateAnchor(newAnchor, from: query)
            //结果在后台匿名队列返回
            Network.push(addedSamples: samplesOrNil, deletedSamples: deletedObjectsOrNil)
        }
        HealthData.healthStore.execute(query)
        queries.append(query)
    }
    func performQuery(completion:@escaping () -> Void) {
        //对于每一个数据类型创建请求
        for (index, item) in data.enumerated() {
            //设置数据
            let now=Date()
            let startDate=getLastWeekStartDate()
            let endDate=now
            let predicate=createLastWeekPredicate()
            let dateInterval=DateComponents(day: 1)
            //处理数据
            let statisticOptions=getStatisticsOptions(for: item.dataTypeIdentifier)
            let initialResultsHandler: (HKStatisticsCollection) -> Void={(statisticsCollection) in
                var values: [Double]=[]
                statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistic, stop) in
                    let statisticsQuantity=getStatisticsQuantity(for: statistic, with: statisticOptions)
                    if let unit=preferredUnit(for: item.dataTypeIdentifier),
                       let value=statisticsQuantity?.doubleValue(for: unit){
                        values.append(value)
                    }
                }
                self.data[index].value=values
                completion()
            }
            //获取数据
            HealthData.fetchStatistics(with: HKQuantityTypeIdentifier(rawValue: item.dataTypeIdentifier), predicate: predicate, options: statisticOptions, start: startDate, interval: dateInterval, completion: initialResultsHandler)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
