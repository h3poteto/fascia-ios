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
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    private let hud = HUDManager()
    private let disposeBag = DisposeBag()
    var viewModel: NewTaskViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
        bindViewModel()

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
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(44.0)
        switch(indexPath.section) {
        case 0:
            height = 44.0
            break
        case 1:
            height = 160.0
            break
        default:
            height = 44.0
            break
        }
        return height
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = String?("")
        switch (section) {
        case 0:
            sectionTitle = "Title"
            break
        case 1:
            sectionTitle = "Description"
            break
        default:
            sectionTitle = ""
            break
        }
        return sectionTitle
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        switch(indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewTaskTitleTableViewCell", for: indexPath) as? NewTaskTitleTableViewCell else {
                return defaultCell
            }
            cell.viewModel = self.viewModel
            return cell
        case (1, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewTaskDescriptionTableViewCell", for: indexPath) as? NewTaskDescriptionTableViewCell else {
                return defaultCell
            }
            cell.viewModel = self.viewModel
            return cell
        default:
            return defaultCell
        }
    }

    private func bindViewModel() {
        hud.bind(loadingTarget: viewModel.isLoading)

        cancelButton
            .rx
            .tap
            .subscribe(onNext: { () in
                self.dismiss(animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

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
                    .disposed(by: self.disposeBag)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

}
