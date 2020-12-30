//
//  ChartViewStyle.swift
//  Walker
//
//  Created by 黎铭轩 on 25/12/2020.
//

import UIKit
import CareKitUI

extension OCKCartesianChartView{
    ///应用标准图表配置设置轴和默认配置样式
    func applyDefaultConfiguration() {
        applyHeaderStyle()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle=NumberFormatter.Style.none
        graphView.numberFormatter=numberFormatter
        graphView.yMinimum=0
    }
    func applyDefaultStyle() {
        headerView.detailLabel.textColor=UIColor.secondaryLabel
    }
    func applyHeaderStyle() {
        applyDefaultStyle()
        customStyle=ChartHeaderStyle()
    }
}
///用带有`.insetGrouped`表格视图作为头部图表样式
struct ChartHeaderStyle: OCKStyler {
    var appearance: OCKAppearanceStyler {
        NoShadowAppearanceStyle()
    }
}
struct NoShadowAppearanceStyle: OCKAppearanceStyler {
    var shadowOpacity1: Float=0
    var shadowOffset1: CGSize=CGSize.zero
    var shadowRadius1: CGFloat=0
}
