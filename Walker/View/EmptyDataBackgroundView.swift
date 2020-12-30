//
//  EmptyDataBackgroundView.swift
//  Walker
//
//  Created by 黎铭轩 on 30/11/2020.
//

import UIKit
private extension CGFloat{
    static let horizontalInset: CGFloat=60
}
///一个带有居中标签告诉没有数据
class EmptyDataBackgroundView: UIView {
    var labelText: String!
    init(message: String) {
        self.labelText=message
        super.init(frame: CGRect.zero)
        setupViews()
        label.text=message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
        addSubview(label)
        addConstraints()
    }
    lazy var label: UILabel = {
        let label=UILabel()
        label.translatesAutoresizingMaskIntoConstraints=false
        label.textColor=UIColor.secondaryLabel
        label.textAlignment=NSTextAlignment.center
        label.font=UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.regular)
        label.numberOfLines=0
        return label
    }()
    func addConstraints() {
        var constraints: [NSLayoutConstraint]=[]
        constraints += addLabelConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    func addLabelConstraints() -> [NSLayoutConstraint] {
        return [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .horizontalInset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.horizontalInset),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
