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
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    private let disposeBag = DisposeBag()
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewProjectTitleTableViewCell", forIndexPath: indexPath) as? NewProjectTitleTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        case (1, 0):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewProjectDescriptionTableViewCell", forIndexPath: indexPath) as? NewProjectDescriptionTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        case (1, 1):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewProjectRepositoryTableViewCell", forIndexPath: indexPath) as? NewProjectRepositoryTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
    }


    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            return indexPath
        default:
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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

    private func showSignInView() {
        if let signIn = UIStoryboard.instantiateViewController("SignInViewController", storyboardName: "Main") as? UIViewController {
            self.presentViewController(signIn, animated: true, completion: nil)
        }
    }

    private func bindViewModel() {
        cancelButton.rx_tap
            .subscribeNext { () in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)

        saveButton.rx_tap
            .subscribeNext { () in
                self.viewModel.save()
                    .doOnError({ (errorType) in
                        switch errorType {
                        case NewProjectValidationError.TitleError:
                            CSNotificationView.showInViewController(self, style: .Error, message: "Title is invalid")
                            break
                        default:
                            CSNotificationView.showInViewController(self, style: .Error, message: "Some items are invalid")
                            break
                        }
                    })
                    .subscribeNext({ (result) in
                        if result {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
    }

    private func bindRepositoryViewModel() {
        repositoryViewModel.fetch()
        repositoryViewModel.dataUpdated
            .driveNext { (repositories) in
                self.repositoryViewModel.repositories = repositories
            }
            .addDisposableTo(disposeBag)
        repositoryViewModel.isLoading
            .driveNext { (loading) in
                if loading {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                } else {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
            .addDisposableTo(disposeBag)
        repositoryViewModel.error
            .driveNext { (error) in
                if error != nil {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
            .addDisposableTo(disposeBag)
        repositoryViewModel.selectedRepository.asDriver()
            .driveNext { (repository) in
                self.viewModel.repository.value = repository
            }
            .addDisposableTo(disposeBag)
    }

}
