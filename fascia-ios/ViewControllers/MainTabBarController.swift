//
//  MainTabBarController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import FontAwesomeKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initViewControllers()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initViewControllers() {
        guard let projects = UIStoryboard.instantiateViewController("ProjectsNavigationViewController", storyboardName: "Projects") as? UINavigationController else {
            return
        }
        projects.tabBarItem.image = UIImage(named: "Projects")
        guard let settings = UIStoryboard.instantiateViewController("SettingsNavigationViewController", storyboardName: "Settings") as? UINavigationController else {
            return
        }
        settings.tabBarItem.image = UIImage(named: "Settings")
        self.setViewControllers([projects, settings], animated: true)
    }

}
