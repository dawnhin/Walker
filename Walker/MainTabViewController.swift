//
//  MainTabViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 29/11/2020.
//

import UIKit
import HealthKit

class MainTabViewController: UITabBarController {
    //MARK: - 初始化
    init() {
        super.init(nibName: nil, bundle: nil)
        setUpTabViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 设置
    func setUpTabViewController() {
        let viewControllers = [
            createWelcomeViewController(),
            createWeeklyQuantitySampleTableViewController(),
            createChartViewController(),
            createWeeklyReportViewController()
        ]
        self.viewControllers=viewControllers.map({
            UINavigationController(rootViewController: $0)
        })
        delegate=self
        selectedIndex=getLastViewedViewControllerIndex()
    }
    private func createWelcomeViewController() -> UIViewController{
        let viewController=WelcomeViewController()
        viewController.tabBarItem=UITabBarItem(title: "欢迎", image: UIImage(systemName: "circle"), selectedImage: UIImage(systemName: "circle.fill"))
        return viewController
    }
    private func createWeeklyQuantitySampleTableViewController() -> UIViewController{
        let dataTypeIdentifier=HKQuantityTypeIdentifier.stepCount.rawValue
        let viewController=WeeklyQuantitySampleTableViewController(dataTypeIdentifier: dataTypeIdentifier)
        viewController.tabBarItem=UITabBarItem(title: "健康数据", image: UIImage(systemName: "triangle"), selectedImage: UIImage(systemName: "triangle.fill"))
        return viewController
    }
    private func createChartViewController() -> UIViewController{
        let viewController=MobilityChartDataViewController()
        viewController.tabBarItem=UITabBarItem(title: "图表", image: UIImage(systemName: "square"), selectedImage: UIImage(systemName: "square.fill"))
        return viewController
    }
    private func createWeeklyReportViewController() -> UIViewController{
        let viewController=WeeklyReportTableViewController()
        viewController.tabBarItem=UITabBarItem(title: "周报", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        return viewController
    }
    //MARK: - 视图持续化
    private static let lastViewControllerViewed="LastViewControllerViewed"
    private func getLastViewedViewControllerIndex() -> Int{
        if let index = UserDefaults.standard.object(forKey: MainTabViewController.lastViewControllerViewed) as? Int {
            return index
        }
        return 0//默认是第一个视图控制器
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
extension MainTabViewController: UITabBarControllerDelegate{
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        setLastViewedViewControllerIndex(index)
    }
    private func setLastViewedViewControllerIndex(_ index: Int){
        UserDefaults.standard.setValue(index, forKey: MainTabViewController.lastViewControllerViewed)
    }
}
