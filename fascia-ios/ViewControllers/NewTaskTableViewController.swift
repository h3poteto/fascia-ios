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
    @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: NewTaskViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        switch(indexPath.row) {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewTaskTitleTableViewCell", for: indexPath) as? NewTaskTitleTableViewCell else {
                return defaultCell
            }
            cell.viewModel = self.viewModel
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewTaskDescriptionTableViewCell", for: indexPath) as? NewTaskDescriptionTableViewCell else {
                return defaultCell
            }
            cell.viewModel = self.viewModel
            return cell
        default:
            return defaultCell
        }
    }

    fileprivate func bindViewModel() {
        cancelButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.dismiss(animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        saveButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.viewModel.save()
                    .subscribe(onNext: { (result) in
                            if result {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }, onError: { (errorType) in
                            switch errorType {
                            case NewTaskValidationError.titleError:
                                CSNotificationView.show(in: self, style: .error, message: "Title is invalid")
                                break
                            default:
                                CSNotificationView.show(in: self, style: .error, message: "Some items are invalid")
                                break
                            }
                        }, onCompleted: nil, onDisposed: nil
                    )
                    .addDisposableTo(self.disposeBag)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

}
