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
import SESlideTableViewCell
import ChameleonFramework

class ListsTableViewController: UITableViewController, UIGestureRecognizerDelegate, ContextMenuDelegate {
    @IBOutlet private weak var refresh: UIRefreshControl!
    private let newListButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: nil, action: nil)
    var viewModel: ListsViewModel!
    private let hud = HUDManager()
    private let disposeBag = DisposeBag()
    var tableTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = newListButton
        bindViewModel()

        self.title = tableTitle

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ListsTableViewController.cellLongPressed(_:)))
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let lists = viewModel.lists else {
            return 0
        }
        return lists.lists.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "ListSectionTableViewCell", bundle: nil)
        guard let sectionView = nib.instantiate(withOwner: nil, options: nil)[0] as? ListSectionTableViewCell else {
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
            bindListSectionViewModel(vm: sectionVM)
            sectionView.viewModel = sectionVM
            return sectionView
        } else {
            if lists.lists.count < 1 {
                return sectionView
            }
            let sectionVM = ListSectionViewModel(model: lists.lists[section - 1])
            bindListSectionViewModel(vm: sectionVM)
            sectionView.viewModel = sectionVM
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.setTitle("Edit", for: UIControl.State())
            button.setTitleColor(UIColor.white, for: UIControl.State())
            button
                .rx
                .tap
                .subscribe(onNext: { () in
                    sectionView.setSlideState(SESlideTableViewCellSlideState.center, animated: true)
                    guard let editListNavigation = UIStoryboard.instantiateViewController(identifier: "EditListNavigationController", storyboardName: "Lists") as? UINavigationController else {
                        return
                    }
                    let editListView = editListNavigation.viewControllers.first as? EditListTableViewController
                    let vm = EditListViewModel(model: lists.lists[section - 1])
                    self.bindEditListViewModel(vm: vm)
                    editListView?.viewModel = vm
                    self.show(editListNavigation, sender: nil)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)

            sectionView.removeAllRightButtons()
            sectionView.addRightButton(button, buttonWidth: 60.0, backgroundColor: UIColor.flatGray())
            return sectionView
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        guard let lists = viewModel.lists else {
            return defaultCell
        }
        guard let noneList = lists.noneList else {
            return defaultCell
        }
        switch (indexPath.section, indexPath.row) {
        case (0, 0..<(noneList.listTasks.count)):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else {
                return defaultCell
            }
            cell.viewModel = TaskCellViewModel(model: noneList.listTasks[indexPath.row], list: noneList)
            return cell
        case (0, noneList.listTasks.count):
            guard let addCell = tableView.dequeueReusableCell(withIdentifier: "AddTaskTableViewCell", for: indexPath) as? AddTaskTableViewCell else {
                return defaultCell
            }
            return addCell
        case (1..<(lists.lists.count + 1), 0..<(lists.lists[indexPath.section - 1].listTasks.count)):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else {
                return defaultCell
            }
            cell.viewModel = TaskCellViewModel(model: lists.lists[indexPath.section - 1].listTasks[indexPath.row], list: lists.lists[indexPath.section - 1])
            return cell
        case (1..<(lists.lists.count + 1), lists.lists[indexPath.section - 1].listTasks.count):
            guard let addCell = tableView.dequeueReusableCell(withIdentifier: "AddTaskTableViewCell", for: indexPath) as? AddTaskTableViewCell else {
                return defaultCell
            }
            return addCell
        default:
            return defaultCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lists = viewModel.lists else {
            return
        }
        guard let noneList = lists.noneList else {
            return
        }
        switch (indexPath.section, indexPath.row) {
        // 各リストの最下部にはタスク追加ボタンを配置してある
        // それらのハンドリング処理
        case (0, noneList.listTasks.count):
            prepareNewTaskView(list: noneList)
                .observeOn(Scheduler.sharedInstance.mainScheduler)
                .subscribeOn(Scheduler.sharedInstance.mainScheduler)
                .subscribe(onNext: { (navigation) in
                    self.show(navigation, sender: nil)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            return
        case (1..<(lists.lists.count + 1), lists.lists[indexPath.section - 1].listTasks.count):
            prepareNewTaskView(list: lists.lists[indexPath.section - 1])
                .observeOn(Scheduler.sharedInstance.mainScheduler)
                .subscribeOn(Scheduler.sharedInstance.mainScheduler)
                .subscribe(onNext: { (navigation) in
                    self.show(navigation, sender: nil)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            return
        // 各タスクの詳細画面を表示
        case (0, 0..<(noneList.listTasks.count)):
            if let taskView = UIStoryboard.instantiateViewController(identifier: "TaskTableViewController", storyboardName: "Task") as? TaskTableViewController {
                taskView.viewModel = TaskViewModel(project: viewModel.project, list: noneList, task: noneList.listTasks[indexPath.row])
                self.navigationController?.pushViewController(taskView, animated: true)
            }
            return
        default:
            if let taskView = UIStoryboard.instantiateViewController(identifier: "TaskTableViewController", storyboardName: "Task") as? TaskTableViewController {
                taskView.viewModel = TaskViewModel(project: viewModel.project, list: lists.lists[indexPath.section - 1], task: lists.lists[indexPath.section - 1].listTasks[indexPath.row])
                self.navigationController?.pushViewController(taskView, animated: true)
            }
            return
        }
    }

    @objc func cellLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        if viewModel.contextMenuVisible {
            return
        }
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)

        if indexPath != nil && recognizer.state == UIGestureRecognizer.State.began {
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
        viewModel.moveRequest(item: item, task: task)
    }

    func closeContextMenu() {
        viewModel.contextMenuVisible = false
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    //------------------------------------------

    private func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController(identifier: "SignInViewController", storyboardName: "Main") as? UIViewController {
            self.present(signIn, animated: true, completion: nil)
        }
    }

    private func showNewListView() {
        if let newListNavigation = UIStoryboard.instantiateViewController(identifier: "NewListNavigationController", storyboardName: "Lists") as? UINavigationController {
            let newListView = newListNavigation.viewControllers.first as? NewListTableViewController
            let vm = NewListViewModel(model: NewList(), project: viewModel.project)
            newListView?.viewModel = vm
            bindNewListViewModel(vm: vm)
            show(newListNavigation, sender: nil)
        }
    }

    private func prepareNewTaskView(list: List) -> Observable<UINavigationController> {
        return Observable.create({ observe -> Disposable in
            if let newTaskNavigation = UIStoryboard.instantiateViewController(identifier: "NewTaskNavigationController", storyboardName: "Task") as? UINavigationController {
                let newTaskView = newTaskNavigation.viewControllers.first as? NewTaskTableViewController
                let vm = NewTaskViewModel(model: NewTask(), list: list)
                newTaskView?.viewModel = vm
                self.bindNewTaskViewModel(vm: vm)
                observe.onNext(newTaskNavigation)
            }
            observe.onCompleted()
            return Disposables.create()
        })
    }

    private func bindViewModel() {
        viewModel.listsUpdated
            .drive(onNext: { (lists) in
                self.viewModel.lists = lists
                self.tableView.reloadData()
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        viewModel.isLoading
            .drive(self.refresh.rx.isRefreshing)
            .disposed(by: disposeBag)

        hud.bind(loadingTarget: viewModel.isLoading)

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
                    CSNotificationView.show(in: self, style: .error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: .error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        refresh.rx.controlEvent(.valueChanged).startWith({ print("start lists loading") }())
            .subscribe(onNext: { () in
                self.viewModel.fetch()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        newListButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.showNewListView()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

    }

    private func bindListSectionViewModel(vm: ListSectionViewModel) {
        vm.listsUpdated
            .drive(onNext: { (lists) in
                if lists != nil {
                    self.viewModel.lists = lists
                    self.tableView.reloadData()
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        vm.isLoading
            .drive(self.refresh.rx.isRefreshing)
            .disposed(by: disposeBag)

        vm.err
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
                    CSNotificationView.show(in: self, style: .error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: .error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func bindNewListViewModel(vm: NewListViewModel) {
        vm.dataUpdated
            .drive(onNext: { (list) in
                if list != nil {
                    CSNotificationView.show(in: self, style: .success, message: "List save complete")
                    self.viewModel.fetch()
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        vm.isLoading
            .drive(self.refresh.rx.isRefreshing)
            .disposed(by: disposeBag)

        vm.err
            .drive(onNext: { (errorType) in
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
                    CSNotificationView.show(in: self, style: .error, message: "The request is invalid")
                    break
                case FasciaAPIError.serverError, ProjectError.parserError, ProjectError.mappingError:
                    CSNotificationView.show(in: self, style: .error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: .error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func bindEditListViewModel(vm: EditListViewModel) {
        vm.dataUpdated
            .drive(onNext: { (list) in
                if list != nil {
                    CSNotificationView.show(in: self, style: .success, message: "List save complete")
                    self.viewModel.fetch()
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        vm.isLoading
            .drive(self.refresh.rx.isRefreshing)
            .disposed(by: disposeBag)

        vm.err
            .drive(onNext: { (errorType) in
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
                    CSNotificationView.show(in: self, style: .error, message: "The request is invalid")
                    break
                case FasciaAPIError.serverError, ProjectError.parserError, ProjectError.mappingError:
                    CSNotificationView.show(in: self, style: .error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: .error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func bindNewTaskViewModel(vm: NewTaskViewModel) {
        vm.dataUpdated
            .drive(onNext: { (task) in
                if task != nil {
                    CSNotificationView.show(in: self, style: .success, message: "Task save complete")
                    self.viewModel.fetch()
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        vm.isLoading
            .drive(self.refresh.rx.isRefreshing)
            .disposed(by: disposeBag)

        vm.err
            .drive(onNext: { (errorType) in
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
                    CSNotificationView.show(in: self, style: .error, message: "The request is invalid")
                    break
                case FasciaAPIError.serverError, ProjectError.parserError, ProjectError.mappingError:
                    CSNotificationView.show(in: self, style: .error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: .error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
