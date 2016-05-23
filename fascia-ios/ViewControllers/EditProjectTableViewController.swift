//
//  EditProjectTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/22.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView

class EditProjectTableViewController: UITableViewController {
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    var viewModel: EditProjectViewModel!
    private let disposeBag = DisposeBag()

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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("EditProjectTitleTableViewCell", forIndexPath: indexPath) as? EditProjectTitleTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.viewModel = self.viewModel
            return cell
        case (0, 1):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("EditProjectDescriptionTableViewCell", forIndexPath: indexPath) as? EditProjectDescriptionTableViewCell else {
                return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            cell.viewModel = self.viewModel
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
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
                        case EditProjectValidationError.TitleError:
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
}
