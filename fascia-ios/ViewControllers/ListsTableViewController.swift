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

class ListsTableViewController: UITableViewController, UIGestureRecognizerDelegate, ContextMenuDelegate {
    @IBOutlet private weak var refresh: UIRefreshControl!
    private let newListButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: nil, action: nil)
    var viewModel: ListsViewModel!
    private let hud = HUDManager()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = newListButton
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
            if noneList.isHidden! {
                return 0
            }
            return noneList.listTasks.count + 1
        } else {
            if lists.lists.count < 1 {
                return 0
            }
            if lists.lists[section - 1].isHidden! {
                return 0
            }
            return lists.lists[section - 1].listTasks.count + 1
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
        let defaultCell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        guard let lists = viewModel.lists else {
            return defaultCell
        }
        guard let noneList = lists.noneList else {
            return defaultCell
        }
        switch (indexPath.section, indexPath.row) {
        case (0, 0..<(noneList.listTasks.count)):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("TaskTableViewCell", forIndexPath: indexPath) as? TaskTableViewCell else {
                return defaultCell
            }
            cell.viewModel = TaskCellViewModel(model: noneList.listTasks[indexPath.row], list: noneList)
            return cell
        case (0, noneList.listTasks.count):
            guard let addCell = tableView.dequeueReusableCellWithIdentifier("AddTaskTableViewCell", forIndexPath: indexPath) as? AddTaskTableViewCell else {
                return defaultCell
            }
            return addCell
        case (1..<(lists.lists.count + 1), 0..<(lists.lists[indexPath.section - 1].listTasks.count)):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("TaskTableViewCell", forIndexPath: indexPath) as? TaskTableViewCell else {
                return defaultCell
            }
            cell.viewModel = TaskCellViewModel(model: lists.lists[indexPath.section - 1].listTasks[indexPath.row], list: lists.lists[indexPath.section - 1])
            return cell
        case (1..<(lists.lists.count + 1), lists.lists[indexPath.section - 1].listTasks.count):
            guard let addCell = tableView.dequeueReusableCellWithIdentifier("AddTaskTableViewCell", forIndexPath: indexPath) as? AddTaskTableViewCell else {
                return defaultCell
            }
            return addCell
        default:
            return defaultCell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // AddCellだったときだけ処理する
        guard let lists = viewModel.lists else {
            return
        }
        guard let noneList = lists.noneList else {
            return
        }
        switch (indexPath.section, indexPath.row) {
        case (0, noneList.listTasks.count):
            showNewTaskView(noneList)
            return
        case (1..<(lists.lists.count + 1), lists.lists[indexPath.section - 1].listTasks.count):
            showNewTaskView(lists.lists[indexPath.section - 1])
            return
        default:
            return
        }
    }

    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        if viewModel.contextMenuVisible {
            return
        }
        // 押された位置でcellのPathを取得
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)

        if indexPath != nil && recognizer.state == UIGestureRecognizerState.Began {
            guard let lists = viewModel.lists else {
                return
            }
            guard let noneList = lists.noneList else {
                return
            }
            // AddCellだった場合を除外する
            switch (indexPath!.section, indexPath!.row) {
            case (0, noneList.listTasks.count):
                return
            case (1..<(lists.lists.count + 1), lists.lists[indexPath!.section - 1].listTasks.count):
                return
            default:
                break
            }
            let task: Task
            if indexPath?.section == 0 {
                task = noneList.listTasks[indexPath!.row]
            } else {
                task = lists.lists[indexPath!.section - 1].listTasks[indexPath!.row]
            }
            let items = viewModel.contextItems()
            let overlay = ContextMenuViewController(items: items, task: task, inViewController: self)
            overlay.delegate = self
            overlay.start(recognizer)
            viewModel.contextMenuVisible = true
        }
    }

    //------------------------------------------
    // ContextMenuDelegate
    //------------------------------------------
    func itemTap(item: ContextItem, task: Task) {
        viewModel.moveRequest(item, task: task)
    }

    func closeContextMenu() {
        viewModel.contextMenuVisible = false
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    //------------------------------------------


    private func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? UIViewController {
            self.presentViewController(signIn, animated: true, completion: nil)
        }
    }

    private func showNewListView() {
        if let newListNavigation = UIStoryboard.instantiateViewController("NewListNavigationController", storyboardName: "Lists") as? UINavigationController {
            let newListView = newListNavigation.viewControllers.first as? NewListTableViewController
            let vm = NewListViewModel(model: NewList(), project: viewModel.project)
            newListView?.viewModel = vm
            bindNewListViewModel(vm)
            showViewController(newListNavigation, sender: nil)
        }
    }

    private func showNewTaskView(list: List) {
        if let newTask = UIStoryboard.instantiateViewController("NewTaskTableViewController", storyboardName: "Lists") as? NewTaskTableViewController {
            let vm = NewTaskViewModel(model: NewTask(), list: list)
            newTask.viewModel = vm
            bindNewTaskViewModel(vm)
            showViewController(newTask, sender: nil)
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
        hud.bind(viewModel.isLoading)

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

        newListButton.rx_tap
            .subscribeNext { () in
                self.showNewListView()
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

    private func bindNewListViewModel(vm: NewListViewModel) {
        vm.dataUpdated
            .driveNext { (list) in
                if list != nil {
                    CSNotificationView.showInViewController(self, style: .Success, message: "List save complete")
                    self.viewModel.fetch()
                }
            }
            .addDisposableTo(disposeBag)
        vm.isLoading
            .drive(self.refresh.rx_refreshing)
            .addDisposableTo(disposeBag)

        vm.error
            .driveNext { (errorType) in
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
                    CSNotificationView.showInViewController(self, style: .Error, message: "The request is invalid")
                    break
                case FasciaAPIError.ServerError, ProjectError.ParserError, ProjectError.MappingError:
                    CSNotificationView.showInViewController(self, style: .Error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.showInViewController(self, style: .Error, message: "Network error.")
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }

    private func bindNewTaskViewModel(vm: NewTaskViewModel) {
        vm.dataUpdated
            .driveNext { (task) in
                if task != nil {
                    CSNotificationView.showInViewController(self, style: .Success, message: "Task save complete")
                    self.viewModel.fetch()
                }
            }
            .addDisposableTo(disposeBag)
        vm.isLoading
            .drive(self.refresh.rx_refreshing)
            .addDisposableTo(disposeBag)

        vm.error
            .driveNext { (errorType) in
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
                    CSNotificationView.showInViewController(self, style: .Error, message: "The request is invalid")
                    break
                case FasciaAPIError.ServerError, ProjectError.ParserError, ProjectError.MappingError:
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
