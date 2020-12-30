//
//  HealthData.swift
//  Walker
//
//  Created by 黎铭轩 on 29/11/2020.
//

import Foundation
import HealthKit

class HealthData {
    static let healthStore: HKHealthStore=HKHealthStore()
    //MARK: - 数据类型
    static var readDataTypes: [HKSampleType]{
        return allHealthDataTypes
    }
    static var shareDataTypes: [HKSampleType]{
        return allHealthDataTypes
    }
    private static var allHealthDataTypes: [HKSampleType]{
        let typeIdentifiers: [String]=[
            HKQuantityTypeIdentifier.stepCount.rawValue,
            HKQuantityTypeIdentifier.distanceCycling.rawValue,
            HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue
        ]
        return typeIdentifiers.compactMap {
            getSampleType(for: $0)
        }
    }
    //MARK: - 授权
    ///如果有需要从HealthKit请求健康数据，在'HealthData.allHealthDataTypes'用数据类型
    class func requestHealthDataAccessIfNeeded(dataTypes: [String]?=nil, completion:@escaping (_ success: Bool)->Void){
        var readDataTypes=Set(allHealthDataTypes)
        var shareDataTypes=Set(allHealthDataTypes)
        if let dataTypeIdentifiers = dataTypes {
            readDataTypes=Set(dataTypeIdentifiers.compactMap({
                getSampleType(for: $0)
            }))
            shareDataTypes=readDataTypes
        }
        requestHealthDataAccessIfNeeded(toShare: shareDataTypes, read: readDataTypes, completion: completion)
    }
    class func requestHealthDataAccessIfNeeded(toShare shareTypes:Set<HKSampleType>?, read readTypes:Set<HKObjectType>?, completion:@escaping (_ success: Bool) -> Void){
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("健康数据不可用!")
        }
        print("请求健康数据授权中...")
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            if let error=error{
                print("请求健康授权错误:\(error.localizedDescription)")
            }
            if success{
                print("请求健康授权成功!")
            }else{
                print("请求健康授权不成功。")
            }
            completion(success)
        }
    }
    //MARK: - HKHealthStore
    class func saveHealthData(_ data: [HKObject], completion: @escaping(_ success: Bool, _ error:Error?) -> Void){
        healthStore.save(data, withCompletion: completion)
    }
    //MARK: - HKStatisticsCollectionQuery
    class func fetchStatistics(with identifier: HKQuantityTypeIdentifier, predicate: NSPredicate?=nil, options: HKStatisticsOptions, start: Date, end: Date=Date(), interval: DateComponents, completion: @escaping(HKStatisticsCollection)-> Void){
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { fatalError("*** 不能创建步数类型 ***") }
        let anchorDate=createAnchorDate()
        //创建查询
        let query=HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: options, anchorDate: anchorDate, intervalComponents: interval)
        //设置结果处理者
        query.initialResultsHandler={query, statistics, error in
            if let statsCollection = statistics {
                completion(statsCollection)
            }
        }
        healthStore.execute(query)
    }
    //MARK: - 助手方法
    class func updateAnchor(_ newAnchor: HKQueryAnchor?, from query: HKAnchoredObjectQuery){
        if let sampleType = query.objectType as? HKSampleType {
            setAnchor(newAnchor, for: sampleType)
        }else{
            if let identifier = query.objectType?.identifier {
                print("anchoredObjectQueryDidUpdate错误:没有用\(identifier)保存-不是一个HKSampleType")
            }else{
                print("anchoredObjectQueryDidUpdate错误:查询没有非空对象")
            }
        }
    }
    private static let userDefaults=UserDefaults.standard
    private static let anchorKeyPrefix="Anchor_"
    private class func anchorKey(for type: HKSampleType) -> String{
        return anchorKeyPrefix+type.identifier
    }
    ///用特定样本类型返回用于长期查询对象
    ///如果查询从没运行返回空
    class func getAnchor(for type: HKSampleType) -> HKQueryAnchor?{
        if let anchorData = userDefaults.object(forKey: anchorKey(for: type)) as? Data {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData)
        }
        return nil
    }
    ///用特定样本类型更新用于长期查询对象
    private class func setAnchor(_ queryAnchor: HKQueryAnchor?, for type: HKSampleType){
        if let queryAnchor = queryAnchor, let data=try? NSKeyedArchiver.archivedData(withRootObject: queryAnchor, requiringSecureCoding: true) {
            userDefaults.set(data, forKey: anchorKey(for: type))
        }
    }
}
