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
import SESlideTableViewCell
import ChameleonFramework

class ProjectsTableViewController: UITableViewController, SideMenuable {
    @IBOutlet fileprivate weak var refresh: UIRefreshControl!
    @IBOutlet fileprivate weak var newProjectButton: UIBarButtonItem!
    fileprivate var viewModel = ProjectsViewModel()
    var disposeBag = DisposeBag()
    var openSideMenu: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "SideMenu"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell", for: indexPath) as? ProjectTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        }
        let project = viewModel.projects[indexPath.row]
        cell.viewModel = ProjectCellViewModel(model: project)
        let button = UIButton(type: UIButtonType.custom)
        button.setTitle("Edit", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button
            .rx
            .tap
            .subscribe(onNext: { () in
                cell.setSlideState(SESlideTableViewCellSlideState.center, animated: true)
                guard let editProjectNavigation = UIStoryboard.instantiateViewController("EditProjectNavigationController", storyboardName: "Projects") as? UINavigationController else {
                    return
                }
                let editProject = editProjectNavigation.viewControllers.first as? EditProjectTableViewController
                guard let indexPath = tableView.indexPath(for: cell) else { return }
                let vm = EditProjectViewModel(project: self.viewModel.projects[indexPath.row])
                self.bindEditProjectViewModel(vm)
                editProject?.viewModel = vm
                self.show(editProjectNavigation, sender: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        cell.addRightButton(button, buttonWidth: 60.0, backgroundColor: UIColor.flatGray)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let listsView = UIStoryboard.instantiateViewController("ListsTableViewController", storyboardName: "Lists") as? ListsTableViewController {
            listsView.viewModel = ListsViewModel(project: viewModel.projects[indexPath.row])
            self.navigationController?.pushViewController(listsView, animated: true)
        }
    }

    fileprivate func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? SignInViewController {
            signIn.rx_viewDidDisappear
                .subscribe(onNext: { () in
                    self.viewModel.fetch()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
            self.present(signIn, animated: true, completion: nil)
        }
    }

    fileprivate func bindViewModel() {
        viewModel.dataUpdated
            .drive(onNext: { (projects) in
                self.viewModel.projects = projects
                self.tableView.reloadData()
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
                    CSNotificationView.show(in: self, style: .error, message: "We're sorry, but something went wrong.")
                    break
                default:
                    CSNotificationView.show(in: self, style: .error, message: "Network error.")
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        refresh.rx.controlEvent(.valueChanged).startWith({ print("start init loading") }())
            .subscribe(onNext: { () in
                self.viewModel.fetch()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        newProjectButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.showNewProject()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

    }

    fileprivate func showNewProject() {
        guard let newProjectNavigation = UIStoryboard.instantiateViewController("NewProjectNavigationViewController", storyboardName: "Projects") as? UINavigationController else {
            return
        }
        let newProjectView = newProjectNavigation.viewControllers.first as? NewProjectTableViewController
        let vm = NewProjectViewModel(model: NewProject())
        newProjectView?.viewModel = vm
        bindNewProjectViewModel(vm)
        self.present(newProjectNavigation, animated: true, completion: nil)
    }

    // 新規プロジェクト作成のViewModelとのつなぎ込みで，このviewに関係あるものをここで設定
    // 管理的にはここに居ないほうがわかりやすかもしれない
    fileprivate func bindNewProjectViewModel(_ vm: NewProjectViewModel) {
        vm.dataUpdated
            .drive(onNext: { (project) in
                if project != nil {
                    CSNotificationView.show(in: self, style: .success, message: "Save complete")
                    self.viewModel.fetch()
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

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
            .addDisposableTo(disposeBag)
    }

    fileprivate func bindEditProjectViewModel(_ vm: EditProjectViewModel) {
        vm.dataUpdated
            .drive(onNext: { (project) in
                if project != nil {
                    CSNotificationView.show(in: self, style: .success, message: "Save complete")
                    self.viewModel.fetch()
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

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
            .addDisposableTo(disposeBag)
    }

}
