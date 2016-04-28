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
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        if !viewModel.existSession() {
            showSignInView()
        }

        // TODO: startWithをつけて初回もロードさせる
        self.refreshControl?.rx_controlEvent(UIControlEvents.ValueChanged)
            .flatMap({
                return self.viewModel.fetch()
            })
            .doOnError({ (errorType) in
                self.refreshControl?.endRefreshing()
                switch errorType {
                case FasciaAPIError.AuthenticateError:
                    self.showSignInView()
                    break
                default:
                    print("unexpected error")
                    break
                }
            })
            .subscribeNext({ projects in
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }).addDisposableTo(self.disposeBag)

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
        return viewModel.projects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("ProjectTableViewCell", forIndexPath: indexPath) as? ProjectTableViewCell else {
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        let project = viewModel.projects[indexPath.row]
        cell.viewModel = ProjectViewModel(model: project)
        return cell
    }

    func bindViewModel() {

    }

    func showSignInView() {
        let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as! UIViewController
        self.presentViewController(signIn, animated: true, completion: nil)
    }

}
