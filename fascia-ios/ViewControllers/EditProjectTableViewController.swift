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
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem!
    var viewModel: EditProjectViewModel!
    fileprivate let disposeBag = DisposeBag()

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
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditProjectTitleTableViewCell", for: indexPath) as? EditProjectTitleTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            }
            cell.viewModel = self.viewModel
            return cell
        case (0, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditProjectDescriptionTableViewCell", for: indexPath) as? EditProjectDescriptionTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            }
            cell.viewModel = self.viewModel
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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
                        case EditProjectValidationError.titleError:
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
}
