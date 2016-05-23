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
import CSNotificationView
import SideMenu

class ProjectsTableViewController: UITableViewController, SideMenuable {
    @IBOutlet private weak var refresh: UIRefreshControl!
    @IBOutlet private weak var newProjectButton: UIBarButtonItem!
    private var viewModel = ProjectsViewModel()
    var disposeBag = DisposeBag()
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuSetup(self)
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
        cell.viewModel = ProjectCellViewModel(model: project)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let listsView = UIStoryboard.instantiateViewController("ListsTableViewController", storyboardName: "Lists") as? ListsTableViewController {
            listsView.viewModel = ListsViewModel(project: viewModel.projects[indexPath.row])
            self.navigationController?.pushViewController(listsView, animated: true)
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit") { (action, indexPath) in
            self.tableView.setEditing(false, animated: true)
            guard let editProjectNavigation = UIStoryboard.instantiateViewController("EditProjectNavigationController", storyboardName: "Projects") as? UINavigationController else {
                return
            }
            let editProject = editProjectNavigation.viewControllers.first as? EditProjectTableViewController
            let vm = EditProjectViewModel(project: self.viewModel.projects[indexPath.row])
            self.bindEditProjectViewModel(vm)
            editProject?.viewModel = vm
            self.showViewController(editProjectNavigation, sender: true)
        }
        return [editAction]
    }

    private func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? SignInViewController {
            signIn.rx_viewDidDisappear
                .subscribeNext({ () in
                    self.viewModel.fetch()
                })
                .addDisposableTo(disposeBag)
            self.presentViewController(signIn, animated: true, completion: nil)
        }
    }

    private func bindViewModel() {
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

        refresh.rx_controlEvent(.ValueChanged).startWith({ print("start init loading") }())
            .subscribeNext { () in
                self.viewModel.fetch()
            }
            .addDisposableTo(disposeBag)

        newProjectButton.rx_tap
            .subscribeNext { () in
                self.showNewProject()
            }
            .addDisposableTo(disposeBag)

    }

    private func showNewProject() {
        guard let newProjectNavigation = UIStoryboard.instantiateViewController("NewProjectNavigationViewController", storyboardName: "Projects") as? UINavigationController else {
            return
        }
        let newProjectView = newProjectNavigation.viewControllers.first as? NewProjectTableViewController
        let vm = NewProjectViewModel(model: NewProject())
        newProjectView?.viewModel = vm
        bindNewProjectViewModel(vm)
        self.presentViewController(newProjectNavigation, animated: true, completion: nil)
    }

    // 新規プロジェクト作成のViewModelとのつなぎ込みで，このviewに関係あるものをここで設定
    // 管理的にはここに居ないほうがわかりやすかもしれない
    private func bindNewProjectViewModel(vm: NewProjectViewModel) {
        vm.dataUpdated
            .driveNext { (project) in
                if project != nil {
                    CSNotificationView.showInViewController(self, style: .Success, message: "Save complete")
                    self.viewModel.fetch()
                }
            }
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

    private func bindEditProjectViewModel(vm: EditProjectViewModel) {
        vm.dataUpdated
            .driveNext { (project) in
                if project != nil {
                    CSNotificationView.showInViewController(self, style: .Success, message: "Save complete")
                    self.viewModel.fetch()
                }
            }
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
