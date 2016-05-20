//
//  NewTaskTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView

class NewTaskTableViewController: UITableViewController {
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: nil, action: nil)
    private let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: nil, action: nil)
    private let disposeBag = DisposeBag()
    var viewModel: NewTaskViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
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
        let defaultCell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        switch(indexPath.row) {
        case 0:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewTaskTitleTableViewCell", forIndexPath: indexPath) as? NewTaskTitleTableViewCell else {
                return defaultCell
            }
            cell.viewModel = self.viewModel
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("NewTaskDescriptionTableViewCell", forIndexPath: indexPath) as? NewTaskDescriptionTableViewCell else {
                return defaultCell
            }
            cell.viewModel = self.viewModel
            return cell
        default:
            return defaultCell
        }
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
                            case NewTaskValidationError.TitleError:
                                CSNotificationView.showInViewController(self, style: .Error, message: "Title is invalid")
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
