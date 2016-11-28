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
import ChameleonFramework

class NewListTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: NewListViewModel!

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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NewListTitleTableViewCell", for: indexPath) as? NewListTitleTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (0, 1):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NewListColorTableViewCell", for: indexPath) as? NewListColorTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewListTitleTableViewCell", for: indexPath)
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
            colorPicker.rx_color()
                .subscribe(onNext: { (color) in
                    let colorStr = (color.hexValue() as NSString).substring(from: 1)
                    self.viewModel.update(nil, color: colorStr)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
            // 選択状態を解除してからviewModelのupdateをかけないと，select時のbackgroundColorとしてsetされてしまう
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(colorPicker, animated: true)
            break
        default:
            break
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
                    .subscribe(onNext: { (result) in
                            if result {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }, onError: { (errorType) in
                            switch errorType {
                            case NewListValidationError.titleError:
                                CSNotificationView.show(in: self, style: .error, message: "Title is invalid")
                                break
                            case NewListValidationError.colorError:
                                CSNotificationView.show(in: self, style: .error, message: "Color is invalid")
                                break
                            default:
                                CSNotificationView.show(in: self, style: .error, message: "Some items are invalid")
                                break
                            }
                        }, onCompleted: nil, onDisposed: nil
                    )
                    .addDisposableTo(self.disposeBag)
            }, onError: nil, onCompleted: nil)

            .addDisposableTo(disposeBag)
    }
}
