//
//  MainTabBarController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

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
        let projects = UIStoryboard.instantiateViewController("ProjectsNavigationViewController", storyboardName: "Projects") as! UINavigationController
        let settings = UIStoryboard.instantiateViewController("SettingsNavigationViewController", storyboardName: "Settings") as! UINavigationController
        self.setViewControllers([projects, settings], animated: true)
    }

}