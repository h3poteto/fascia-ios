//
//  SideMenuTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/15.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        default:
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTitleCell", for: indexPath)
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuProjectsCell", for: indexPath)
            return cell
        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuContactCell", for: indexPath)
            return cell
        case (1, 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuSignInCell", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuSignInCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0:
            return 60.0
        default:
            return 45.0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            if let projects = UIStoryboard.instantiateViewController(identifier: "ProjectsTableViewController", storyboardName: "Projects") as? UITableViewController {
                show(projects, sender: nil)
            }
            break
        case (1, 1):
            break
        case (1, 2):
            if let signIn = UIStoryboard.instantiateViewController(identifier: "SignInViewController", storyboardName: "Main") as? UIViewController {
                show(signIn, sender: true)
            }
            break
        default:
            break
        }
        return
    }
}
