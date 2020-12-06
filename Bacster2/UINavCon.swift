//
//  TabBarController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/5/20.
//

import UIKit

class UINavCon: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -----------------------------------------------------------
        // NAVIGATION BAR CUSTOMIZATION
        // -----------------------------------------------------------
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().isTranslucent = false
            
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.green
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance

        } else {
            UINavigationBar.appearance().barTintColor = UIColor.black
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }

        // -----------------------------------------------------------
        // NAVIGATION BAR SHADOW
        // -----------------------------------------------------------
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.navigationController?.navigationBar.layer.shadowRadius = 15
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.7
        
    }
}

