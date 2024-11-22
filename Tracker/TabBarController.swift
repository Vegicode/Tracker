//
//  TabBarController.swift
//  Tracker
//
//  Created by Mac on 01.11.2024.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.whiteYp
            UITabBar.appearance().standardAppearance = tabBarAppearance
            
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
        }
        
        let trackers = TrackersViewController()
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named:"Trackers inActive"),
            selectedImage: UIImage(named: "Trackers Active"))
        
        let statistics = Statistics()
        statistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named:"Statistics inActive"),
            selectedImage: UIImage(named: "Statistics Active"))
        self.viewControllers = [trackers, statistics]
    }
}
