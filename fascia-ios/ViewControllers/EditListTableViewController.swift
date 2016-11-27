//
//  EditListTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CSNotificationView
import ChameleonFramework

class EditListTableViewController: UITableViewController {
    @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: EditListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadOption()
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
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EditListTitleTableViewCell", for: indexPath) as? EditListTitleTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (0, 1):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EditListColorTableViewCell", for: indexPath) as? EditListColorTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (0, 2):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EditListActionTableViewCell", for: indexPath) as? EditListActionTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditListTitleTableViewCell", for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            guard let colorPicker = UIStoryboard.instantiateViewController("ColorPickerViewController", storyboardName: "Lists") as? ColorPickerViewController else {
                return
            }
            guard let color = viewModel.color.value else {
                return
            }
            colorPicker.viewModel = ColorPickerViewModel(color: UIColor(hexString: color)!)
            colorPicker
                .rx_color()
                .subscribe(onNext: { (color) in
                    let colorStr = (color.hexValue() as NSString).substring(from: 1)
                    self.viewModel.update(nil, color: colorStr, option: nil)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
            // 選択状態を解除してからviewModelのupdateをかけないと，select時のbackgroundColorとしてsetされてしまう
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(colorPicker, animated: true)
            break
        case (0, 2):
            listOptionAlert()
            self.tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            break
        }
    }

    fileprivate func listOptionAlert() {
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        viewModel.listOptions.forEach { (listOption) in
            let action = UIAlertAction(title: listOption.action, style: .default, handler: { (optionAction) in
                self.viewModel.update(nil, color: nil, option: listOption)
            })
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
                            case EditListValidationError.titleError:
                                CSNotificationView.show(in: self, style: .error, message: "Title is invalid")
                                break
                            case EditListValidationError.colorError:
                                CSNotificationView.show(in: self, style: .error, message: "Color is invalid")
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
