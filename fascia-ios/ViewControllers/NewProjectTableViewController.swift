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
            return 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewProjectTitleTableViewCell", forIndexPath: indexPath) as? NewProjectTitleTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewProjectDescriptionTableViewCell", forIndexPath: indexPath) as? NewProjectDescriptionTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.parentViewModel = viewModel
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
    }


    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
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


        repositoryViewModel.fetch()
        repositoryViewModel.dataUpdated
            .driveNext { (repositories) in
                self.repositoryViewModel.repositories = repositories
            }
            .addDisposableTo(disposeBag)
    }

}
