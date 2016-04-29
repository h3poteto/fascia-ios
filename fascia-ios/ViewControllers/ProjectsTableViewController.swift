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
import TSMessages


class ProjectsTableViewController: UITableViewController {
    @IBOutlet private weak var refresh: UIRefreshControl!
    private var viewModel = ProjectsViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()

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

    func showSignInView() {
        let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as! UIViewController
        self.presentViewController(signIn, animated: true, completion: nil)
    }

    func bindViewModel() {
        viewModel.dataUpdated
            .driveNext { (projects) in
                self.viewModel.projects = projects
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)

        viewModel.isLoading
            .drive(self.refresh.rx_refreshing)
            .addDisposableTo(disposeBag)

        viewModel.error
            .driveNext { (errorType) in
                self.refresh.endRefreshing()
                guard let errorType = errorType else {
                    return
                }
                switch errorType {
                case FasciaAPIError.AuthenticateError:
                    self.showSignInView()
                    break
                case FasciaAPIError.DoubleRequestError:
                    break
                case FasciaAPIError.ClientError:
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: "The request is invalid.", type: TSMessageNotificationType.Error)
                    break
                case FasciaAPIError.ServerError:
                    TSMessage.showNotificationWithTitle("Server Error", subtitle: "We're sorry, but something went wrong.", type: TSMessageNotificationType.Error)
                    break
                default:
                    TSMessage.showNotificationWithTitle("Error", subtitle: (errorType as NSError).localizedDescription, type: TSMessageNotificationType.Error)
                    break
                }
            }
            .addDisposableTo(disposeBag)

        refresh.rx_controlEvent(.ValueChanged).startWith({ print("start init loading") }())
            .subscribeNext { () in
                self.viewModel.fetch()
            }
            .addDisposableTo(disposeBag)
    }

}
