//
//  UIApplication+Extension.swift
//  Walker
//
//  Created by 黎铭轩 on 22/12/2020.
//

import UIKit
extension UIApplication{
    ///返回是否激活窗口在横行方向
    var isLandscape: Bool {
        windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
    }
}
