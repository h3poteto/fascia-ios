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

class ListsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    @IBOutlet private weak var refresh: UIRefreshControl!
    var viewModel: ListsViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ListsTableViewController.cellLongPressed(_:)))
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
            if lists.lists[section - 1].isHidden! {
                return 0
            }
            return lists.lists[section - 1].listTasks.count
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4.0
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "ListSectionTableViewCell", bundle: nil)
        guard let sectionView = nib.instantiateWithOwner(nil, options: nil)[0] as? ListSectionTableViewCell else {
            return nil
        }
        guard let lists = viewModel.lists else {
            return sectionView
        }
        if section == 0 {
            guard let noneList = lists.noneList else {
                return sectionView
            }
            let sectionVM = ListSectionViewModel(model: noneList)
            bindListSectionViewModel(sectionVM)
            sectionView.viewModel = sectionVM
            return sectionView
        } else {
            if lists.lists.count < 1 {
                return sectionView
            }
            let sectionVM = ListSectionViewModel(model: lists.lists[section - 1])
            bindListSectionViewModel(sectionVM)
            sectionView.viewModel = sectionVM
            return sectionView
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
            cell.viewModel = TaskCellViewModel(model: noneList.listTasks[indexPath.row], list: noneList)
        } else {
            if lists.lists.count < 1 {
                return cell
            }
            cell.viewModel = TaskCellViewModel(model: lists.lists[indexPath.section - 1].listTasks[indexPath.row], list: lists.lists[indexPath.section - 1])
        }
        return cell
    }

    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)

        if indexPath != nil && recognizer.state == UIGestureRecognizerState.Began {
            // 長押しされた場合の処理
            print("長押しされたcellのindexPath:\(indexPath?.row)")
            let items = viewModel.contextItems()
            let overlay = ContextMenuViewController(items: items, inViewController: self)
            overlay.start(recognizer)
        }
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

    private func bindListSectionViewModel(vm: ListSectionViewModel) {
        vm.listsUpdated
            .driveNext { (lists) in
                if lists != nil {
                    self.viewModel.lists = lists
                    self.tableView.reloadData()
                }
            }
            .addDisposableTo(disposeBag)

        vm.isLoading
            .drive(self.refresh.rx_refreshing)
            .addDisposableTo(disposeBag)

        vm.error
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
    }

}
