//
//  TabBarController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/5/20.
//

import UIKit
class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Visual customizations
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = #colorLiteral(red: 0.07450980392, green: 0.07450980392, blue: 0.07450980392, alpha: 1)
        
        // Create Tab one
        let homeVC = HomeViewController()
        let homeTabItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        homeVC.tabBarItem = homeTabItem
        
        
        // Create Tab two
        //let trackerVC = TrackerViewController()
        let trackerNavCon = UINavigationController.init(rootViewController: TrackerViewController())
        trackerNavCon.theme()
        let trackerTabItem = UITabBarItem(title: "Tracker", image:  UIImage(systemName: "plus.app.fill"), tag: 1)
        trackerNavCon.tabBarItem = trackerTabItem
        
        // Create Tab three
        let historyVC = HistoryViewController()
        let historyTabItem = UITabBarItem(title: "History", image:  UIImage(systemName: "chart.bar.fill"), tag: 2)
        historyVC.tabBarItem = historyTabItem
        
        
        self.viewControllers = [homeVC, trackerNavCon, historyVC]
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //print("Selected \(viewController.title!)")
    }
}

