//
//  CareKitSupport.swift
//  Walker
//
//  Created by 黎铭轩 on 24/12/2020.
//

import Foundation

//MARK: - 图表日期UI
///返回一个描述上周图表日期范围。
func createChartWeeklyDateRangeLabel(lastDate:Date=Date()) -> String {
    let calendar: Calendar=Calendar.current
    let endOfWeekDate=lastDate
    let startOfWeekDate=getLastWeekStartDate(from: endOfWeekDate)
    let monthDayDateFormatter=DateFormatter()
    monthDayDateFormatter.dateFormat="MMM d"
    let monthDayYearDateFormatter=DateFormatter()
    monthDayYearDateFormatter.dateFormat="MMM d, yyyy"
    var startDateString=monthDayDateFormatter.string(from: startOfWeekDate)
    var endDateString=monthDayYearDateFormatter.string(from: endOfWeekDate)
    //如果开始和结束在同一个月份
    if calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: Calendar.Component.month) {
        startDateString=monthDayYearDateFormatter.string(from: startOfWeekDate)
    }
    return String(format: "%@-%@", startDateString, endDateString)
}
private func createMonthDayDateFormatter() -> DateFormatter{
    let dateFormatter=DateFormatter()
    dateFormatter.dateFormat="MM/dd"
    return dateFormatter
}
func createChartDateLastUpdatedLabel(_ dateLastUpdated: Date) -> String{
    let dateFormatter=DateFormatter()
    dateFormatter.dateStyle=DateFormatter.Style.medium
    return "上次更新在\(dateFormatter.string(from: dateLastUpdated))时候"
}
///基于指定时间帧返回水平轴标记集合，最后一个标记对应`最后日期`
///`用周日期`将用短日期替代
///默认展示当前日期为图表最后一个轴标签和之前一周日期
func createHorizontalAxisMarkers(lastDate: Date=Date(), useWeekDays: Bool=true) -> [String] {
    let calendar = Calendar.current
    let weekdayTitle = ["周日","周一","周二","周三","周四","周五","周六"]
    var titles: [String]=[]
    if useWeekDays {
        titles=weekdayTitle
        let weekday=calendar.component(.weekday, from: lastDate)
        return Array(titles[weekday..<titles.count])+Array(titles[0..<weekday])
    }else{
        let numberOfTitles=weekdayTitle.count
        let endDate=lastDate
        let startDate = calendar.date(byAdding: DateComponents(day: -(numberOfTitles-1)), to: endDate)
        let dateFormatter=createMonthDayDateFormatter()
        var date=startDate!
        while date<=endDate {
            titles.append(dateFormatter.string(from: date))
            date=calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return titles
    }
}
func createHorizontalAxisMarkers(for dates: [Date]) -> [String]{
    let dateFormatter=createMonthDayDateFormatter()
    return dates.map {
        dateFormatter.string(from: $0)
    }
}
