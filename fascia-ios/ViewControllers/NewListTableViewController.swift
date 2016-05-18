//
//  NewListTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/16.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView

class NewListTableViewController: UITableViewController {
    var viewModel: NewListViewModel!
    private let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: nil, action: nil)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton
        bindViewModel()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            if let cell = tableView.dequeueReusableCellWithIdentifier("NewListTitleTableViewCell", forIndexPath: indexPath) as? NewListTitleTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (0, 1):
            if let cell = tableView.dequeueReusableCellWithIdentifier("NewListColorTableViewCell", forIndexPath: indexPath) as? NewListColorTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        default:
            break
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("NewListTitleTableViewCell", forIndexPath: indexPath)
        return cell
    }

    private func bindViewModel() {
        cancelButton.rx_tap
            .subscribeNext { () in
                self.navigationController?.popViewControllerAnimated(true)
            }
            .addDisposableTo(disposeBag)

        saveButton.rx_tap
            .subscribeNext { () in
                self.viewModel.save()
                    .subscribe(onNext: { (result) in
                            if result {
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }, onError: { (errorType) in
                            switch errorType {
                            case NewListValidationError.TitleError:
                                CSNotificationView.showInViewController(self, style: .Error, message: "Title is invalid")
                                break
                            case NewListValidationError.ColorError:
                                CSNotificationView.showInViewController(self, style: .Error, message: "Color is invalid")
                                break
                            default:
                                CSNotificationView.showInViewController(self, style: .Error, message: "Some items are invalid")
                                break
                            }
                        }, onCompleted: nil, onDisposed: nil
                    )
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
    }
}
