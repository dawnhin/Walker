//
//  HealthKitSupport+Strings.swift
//  Walker
//
//  Created by 黎铭轩 on 2/12/2020.
//

import Foundation
import HealthKit
//MARK: - 数据类型
///用一个HealthKit数据类型标识符返回可读名称
func getDataTypeName(for identifier: String) -> String? {
    var description: String?
    let sampleType=getSampleType(for: identifier)
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier=HKQuantityTypeIdentifier(rawValue: identifier)
        switch quantityTypeIdentifier {
        case .stepCount:
            description="步数"
        case .distanceWalkingRunning:
            description="步行数+跑步"
        case .sixMinuteWalkTestDistance:
            description="六分钟步行"
        default:
            break
        }
    }
    return description
}
//MARK: - 格式化字符串值
///返回一个基于它类型的适合阅读健康值。例如: "10,000 步"
func formattedValue(_ value: Double, typeIdentifier: String) -> String? {
    guard
        let unit=preferredUnit(for: typeIdentifier),
        let roundedValue=getRoundedValue(for: value, with: unit),
        let unitSuffix=getUnitSuffix(for: unit) else {
        return nil
    }
    let formattedString=String.localizedStringWithFormat("%@ %@", roundedValue, unitSuffix)
    return formattedString
}
private func getRoundedValue(for value: Double, with unit: HKUnit) -> String?{
    let numberFormatter=NumberFormatter()
    numberFormatter.numberStyle=NumberFormatter.Style.decimal
    switch unit {
    case .count(), .meter():
        let numberValue=NSNumber(value: round(value))
        return numberFormatter.string(from: numberValue)
    default:
        return nil
    }
}
func getUnitDescription(for unit: HKUnit) -> String?{
    switch unit {
    case .count():
        return "步"
    case .meter():
        return "米"
    default:
        return nil
    }
}
private func getUnitSuffix(for unit: HKUnit) -> String?{
    switch unit {
    case .count():
        return "步"
    case .meter():
        return "米"
    default:
        return nil
    }
}
