//
//  NewProjectTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView

class NewProjectTableViewController: UITableViewController {
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: NewProjectViewModel!
    var repositoryViewModel = RepositoriesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        bindRepositoryViewModel()
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
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectTitleTableViewCell", for: indexPath) as? NewProjectTitleTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        case (1, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectDescriptionTableViewCell", for: indexPath) as? NewProjectDescriptionTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        case (1, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectRepositoryTableViewCell", for: indexPath) as? NewProjectRepositoryTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            return indexPath
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            if let repositories = UIStoryboard.instantiateViewController("RepositoriesTableViewController", storyboardName: "Projects") as? RepositoriesTableViewController {
                repositories.viewModel = self.repositoryViewModel
                self.navigationController?.pushViewController(repositories, animated: true)
            }
            break
        default:
            break
        }
    }

    fileprivate func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? UIViewController {
            self.present(signIn, animated: true, completion: nil)
        }
    }

    fileprivate func bindViewModel() {
        cancelButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.dismiss(animated: true, completion: nil)
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)

        saveButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.viewModel.save()
                    .do(onNext: nil, onError: { (errorType) in
                        switch errorType {
                        case NewProjectValidationError.titleError:
                            CSNotificationView.show(in: self, style: .error, message: "Title is invalid")
                            break
                        default:
                            CSNotificationView.show(in: self, style: .error, message: "Some items are invalid")
                            break
                        }
                    }, onCompleted: nil, onSubscribe: nil, onDispose: nil)
                    .subscribe(onNext: { (result) in
                        if result {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(self.disposeBag)
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)
    }

    fileprivate func bindRepositoryViewModel() {
        repositoryViewModel.fetch()
        repositoryViewModel.dataUpdated
            .drive(onNext: { (repositories) in
                self.repositoryViewModel.repositories = repositories
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        repositoryViewModel.isLoading
            .drive(onNext: { (loading) in
                if loading {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }, onCompleted: nil, onDisposed: nil)

            .addDisposableTo(disposeBag)
        repositoryViewModel.err
            .drive(onNext: { (error) in
                if error != nil {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        repositoryViewModel.selectedRepository.asDriver()
            .drive(onNext: { (repository) in
                self.viewModel.repository.value = repository
                self.viewModel.update(repository?.name, description: nil, repository: repository)
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

}
