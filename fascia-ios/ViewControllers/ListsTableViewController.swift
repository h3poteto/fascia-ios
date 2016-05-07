//
//  ListsTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/06.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView

class ListsTableViewController: UITableViewController {
    @IBOutlet private weak var refresh: UIRefreshControl!
    var viewModel: ListsViewModel!
    private let disposeBag = DisposeBag()

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
        guard let lists = viewModel.lists else {
            return 0
        }
        return lists.lists.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lists = viewModel.lists else {
            return 0
        }
        if section == 0 {
            guard let noneList = lists.noneList else {
                return 0
            }
            return noneList.listTasks.count
        } else {
            if lists.lists.count < 1 {
                return 0
            }
            return lists.lists[section - 1].listTasks.count
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let lists = viewModel.lists else {
            return ""
        }
        if section == 0 {
            guard let noneList = lists.noneList else {
                return ""
            }
            return noneList.title
        } else {
            if lists.lists.count < 1 {
                return ""
            }
            return lists.lists[section - 1].title
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("TaskTableViewCell", forIndexPath: indexPath) as? TaskTableViewCell else {
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        guard let lists = viewModel.lists else {
            return cell
        }
        if indexPath.section == 0 {
            guard let noneList = lists.noneList else {
                return cell
            }
            cell.viewModel = TaskCellViewModel(model: noneList.listTasks[indexPath.row])
        } else {
            if lists.lists.count < 1 {
                return cell
            }
            cell.viewModel = TaskCellViewModel(model: lists.lists[indexPath.section - 1].listTasks[indexPath.row])
        }
        return cell
    }

    private func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? UIViewController {
            self.presentViewController(signIn, animated: true, completion: nil)
        }
    }

    private func bindViewModel() {
        viewModel.listsUpdated
            .driveNext { (lists) in
                self.viewModel.lists = lists
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
                    CSNotificationView.showInViewController(self, style: CSNotificationViewStyle.Error, message: "The request is invalid.")
                    break
                case FasciaAPIError.ServerError:
                    CSNotificationView.showInViewController(self, style: .Error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.showInViewController(self, style: .Error, message: "Network error.")
                    break
                }
            }
            .addDisposableTo(disposeBag)

        refresh.rx_controlEvent(.ValueChanged).startWith({ print("start lists loading") }())
            .subscribeNext { () in
                self.viewModel.fetch()
            }
            .addDisposableTo(disposeBag)

    }

}
