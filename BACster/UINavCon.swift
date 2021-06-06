//
//  TabBarController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/5/20.
//

import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func awakeFromNib() {
        theme()
    }
    
    func theme() {
        
        // -----------------------------------------------------------
        // NAVIGATION BAR CUSTOMIZATION
        // -----------------------------------------------------------
        UINavigationBar.appearance().prefersLargeTitles = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
            
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            //appearance.configureWithDefaultBackground()
            appearance.backgroundColor = #colorLiteral(red: 0.09545650333, green: 0.09545981139, blue: 0.09545803815, alpha: 1)
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
            self.navigationBar.compactAppearance = appearance

        } else {
            UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.09545650333, green: 0.09545981139, blue: 0.09545803815, alpha: 1)
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

