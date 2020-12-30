//
//  HealthKitSupport.swift
//  Walker
//
//  Created by 黎铭轩 on 29/11/2020.
//

import Foundation
import HealthKit

//MARK: 样本类型标识符支持
//返回一个基于输入标识符对应HKQuantityTypeIdentifier，HKCategoryTypeIdentifier或其它合法标识符的HKSampleType。否则返回空。
func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    return nil
}

//MARK: - 单元支持
///基于标识符用一个HKSample返回合适单位。判断合适单位。
func preferredUnit(for sample: HKSample) -> HKUnit? {
    //获取单位
    let unit=preferredUnit(for: sample.sampleType.identifier, sampleType: sample.sampleType)
    if let quantitySample = sample as? HKQuantitySample, let unit=unit {
        assert(quantitySample.quantity.is(compatibleWith: unit), "该偏好单位与样本不匹配")
    }
    return unit
}
///用一个HealthKit数据类型对应标识符返回合适单位
func preferredUnit(for identifier: String) -> HKUnit? {
    return preferredUnit(for: identifier, sampleType: nil)
}
private func preferredUnit(for identifier: String, sampleType: HKSampleType?=nil) -> HKUnit?{
    var unit: HKUnit?
    let sampleType=sampleType ?? getSampleType(for: identifier)
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier=HKQuantityTypeIdentifier(rawValue: identifier)
        switch quantityTypeIdentifier {
        case .stepCount:
            unit = .count()
        case .distanceWalkingRunning, .sixMinuteWalkTestDistance:
            unit = .meter()
        default:
            break
        }
    }
    return unit
}
//MARK: - 查询支持
///返回一个日期用于一个数值集合查询
func createAnchorDate() -> Date {
    //设置模糊日期为星期一上午3:00
    let calendar: Calendar = .current
    var anchorComponents=calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
    let offset=(7+(anchorComponents.weekday ?? 0)-2)%7
    anchorComponents.day! -= offset
    anchorComponents.hour = 3
    let anchorDate=calendar.date(from: anchorComponents)
    return anchorDate!
}
///这是普遍用于日期间隔所以我们获得最后七天数据，
///因为我们假定今天 (`Date()`) 也提供数据
func getLastWeekStartDate(from date: Date=Date()) -> Date {
    Calendar.current.date(byAdding: Calendar.Component.day, value: -6, to: date)!
}
func createLastWeekPredicate(from endDate: Date=Date()) -> NSPredicate{
    let startDate=getLastWeekStartDate(from: endDate)
    return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
}
///用数据类型标识符返回最偏好`HKStatisticsOptions`。默认是`.discreteAverage`。
func getStatisticsOptions(for dataTypeIdentifier: String) -> HKStatisticsOptions {
    var options: HKStatisticsOptions = .discreteAverage
    let sampleType=getSampleType(for: dataTypeIdentifier)
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier=HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)
        switch quantityTypeIdentifier {
        case .stepCount, .distanceWalkingRunning:
            options = .cumulativeSum
        case .sixMinuteWalkTestDistance:
            options = .discreteAverage
        default:
            break
        }
    }
    return options
}
///基于`statisticsOption`返回`statistics`数值
func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
    var statisticsQuantity: HKQuantity?
    switch statisticsOptions {
    case .cumulativeSum:
        statisticsQuantity = statistics.sumQuantity()
    case .discreteAverage:
        statisticsQuantity = statistics.averageQuantity()
    default:
        break
    }
    return statisticsQuantity
}
