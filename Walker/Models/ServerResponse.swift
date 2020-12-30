//
//  ServerResponse.swift
//  Walker
//
//  Created by 黎铭轩 on 27/12/2020.
//

import Foundation
///一个伺服器响应包含周报集合
struct ServerResponse: Codable {
    let identifier: String
    var date: Date
    var weeklyReport: WeeklyReport
}
///从临床医生获取数据集合
struct WeeklyReport: Codable {
    let identifier: String
    var startDate: Date
    var endDate: Date
    var samples: [ServerHealthSample]
}
///健康数据样本
struct ServerHealthSample: Codable {
    let syncIdentifier: String
    let syncVersion: Int
    let type: HealthSampleType
    let typeIdentifier: String
    let unit: String
    let value: Double
    var startDate: Date
    var endDate: Date
}
///HKObjectType类型描述
enum HealthSampleType: String, Codable {
    case category
    case quantity
}
