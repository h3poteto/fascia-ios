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


class ProjectsTableViewController: UITableViewController {
    @IBOutlet private weak var refresh: UIRefreshControl!
    @IBOutlet private weak var newProjectButton: UIBarButtonItem!
    @IBOutlet private weak var openSideMenu: UIBarButtonItem!
    private var viewModel = ProjectsViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        guard let leftNav = UIStoryboard.instantiateViewController("UISideMenuNavigationController", storyboardName: "Main") as? UISideMenuNavigationController else {
            return
        }
        SideMenuManager.menuLeftNavigationController = leftNav
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.navigationBar)

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

    private func showSignInView() {
        // TODO: 初回であればこのあとにロードさせたい
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? UIViewController {
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

        openSideMenu.rx_tap
            .subscribeNext { () in
                self.presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
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

}
