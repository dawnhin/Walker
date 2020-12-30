//
//  DataTypeCollectionViewCell.swift
//  Walker
//
//  Created by 黎铭轩 on 22/12/2020.
//

import UIKit
import CareKitUI

class DataTypeCollectionViewCell: UICollectionViewCell {
    var dataTypeIdentifier: String!
    var statisticalValues: [Double] = []
    var chartView: OCKCartesianChartView={
        let chartView=OCKCartesianChartView(type: OCKCartesianGraphView.PlotType.bar)
        chartView.translatesAutoresizingMaskIntoConstraints=false
        return chartView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    init(dataTypeIdentifier: String) {
        self.dataTypeIdentifier=dataTypeIdentifier
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setUpView(){
        contentView.addSubview(chartView)
        setUpConstraints()
    }
    private func setUpConstraints(){
        var constraints: [NSLayoutConstraint]=[]
        constraints += createChartViewConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    private func createChartViewConstraints() -> [NSLayoutConstraint]{
        let leading=chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let top=chartView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let trailing=chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let bottom=chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        trailing.priority -= 1
        bottom.priority -= 1
        return [leading, trailing, top, bottom]
    }
    func updateChartView(with dataTypeIdentifier: String, values: [Double]) {
        self.dataTypeIdentifier=dataTypeIdentifier
        self.statisticalValues=values
        //更新headerView
        chartView.headerView.titleLabel.text=getDataTypeName(for: dataTypeIdentifier) ?? "数据"
        chartView.headerView.detailLabel.text=createChartWeeklyDateRangeLabel()
        //更新graphView
        chartView.applyDefaultConfiguration()
        chartView.graphView.horizontalAxisMarkers=createHorizontalAxisMarkers()
        //更新graphView日期系列
        let dataPoint: [CGFloat]=statisticalValues.map {
            CGFloat($0)
        }
        guard let unit=preferredUnit(for: dataTypeIdentifier),
              let unitTitle=getUnitDescription(for: unit) else {
            return
        }
        chartView.graphView.dataSeries=[
            OCKDataSeries(values: dataPoint, title: unitTitle)
        ]
    }
}
