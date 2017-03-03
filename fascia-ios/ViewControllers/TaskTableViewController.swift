//
//  TaskTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/02/27.
//  Copyright © 2017年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView

class TaskTableViewController: UITableViewController {
    @IBOutlet private weak var refresh: UIRefreshControl!
    private let hud = HUDManager()
    private let disposeBag = DisposeBag()
    var viewModel: TaskViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension

        bindViewModel()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4.0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = String?("")
        switch (section) {
        case 0:
            sectionTitle = "Title"
            break
        case 1:
            sectionTitle = "Description"
            break
        default:
            sectionTitle = ""
            break
        }
        return sectionTitle
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTitleTableViewCell", for: indexPath) as? TaskTitleTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (1, 0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskDescriptionTableViewCell", for: indexPath) as? TaskDescriptionTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTitleTableViewCell", for: indexPath)
        return cell
    }

    private func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController(identifier: "SignInViewController", storyboardName: "Main") as? UIViewController {
            self.present(signIn, animated: true, completion: nil)
        }
    }

    private func bindViewModel() {
        hud.bind(loadingTarget: viewModel.isLoading)

        viewModel.taskUpdated
            .drive(onNext: { (task) in
                if let task = task {
                    self.viewModel.task = task
                    self.tableView.reloadData()
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        viewModel.isLoading
            .drive(self.refresh.rx.refreshing)
            .addDisposableTo(disposeBag)

        viewModel.err
            .drive(onNext: { (errorType) in
                self.refresh.endRefreshing()
                guard let errorType = errorType else {
                    return
                }
                switch errorType {
                case FasciaAPIError.authenticateError:
                    self.showSignInView()
                    break
                case FasciaAPIError.doubleRequestError:
                    break
                case FasciaAPIError.clientError:
                    CSNotificationView.show(in: self, style: CSNotificationViewStyle.error, message: "The request is invalid.")
                    break
                case FasciaAPIError.serverError:
                    CSNotificationView.show(in: self, style: CSNotificationViewStyle.error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: CSNotificationViewStyle.error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        refresh.rx.controlEvent(.valueChanged).startWith({ print("start lists loading") }())
            .subscribe(onNext: { () in
                self.viewModel.fetch()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
