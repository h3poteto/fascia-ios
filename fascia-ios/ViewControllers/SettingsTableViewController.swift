//
//  SettingsTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
// TODO: これ消す
class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("SignInTableViewCell", forIndexPath: indexPath) as? SignInTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Account"
        default:
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            if let signInView = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? UIViewController {
                self.navigationController?.pushViewController(signInView, animated: true)
            }
            break
        default:
            break
        }
    }
}
