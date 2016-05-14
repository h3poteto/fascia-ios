//
//  SideMenuTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/15.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        default:
            return 2
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuTitleCell", forIndexPath: indexPath)
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuProjectsCell", forIndexPath: indexPath)
            return cell
        case (1, 1):
            let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuSignInCell", forIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SignInTableViewCell", forIndexPath: indexPath)
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0:
            return 60.0
        default:
            return 45.0
        }
    }

}
