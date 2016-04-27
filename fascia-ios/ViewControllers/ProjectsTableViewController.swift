//
//  ProjectsTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProjectsTableViewController: UITableViewController {
    private var viewModel = ProjectsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        if !viewModel.existSession() {
            let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as! UIViewController
            self.presentViewController(signIn, animated: true, completion: nil)
        }

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
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    func bindViewModel() {

    }

}
