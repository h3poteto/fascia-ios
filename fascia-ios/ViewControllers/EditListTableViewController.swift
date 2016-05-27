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

class EditListTableViewController: UITableViewController {
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    private let disposeBag = DisposeBag()
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if let cell = tableView.dequeueReusableCellWithIdentifier("EditListTitleTableViewCell", forIndexPath: indexPath) as? EditListTitleTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (0, 1):
            if let cell = tableView.dequeueReusableCellWithIdentifier("EditListColorTableViewCell", forIndexPath: indexPath) as? EditListColorTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        case (0, 2):
            if let cell = tableView.dequeueReusableCellWithIdentifier("EditListActionTableViewCell", forIndexPath: indexPath) as? EditListActionTableViewCell {
                cell.viewModel = self.viewModel
                return cell
            }
            break
        default:
            break
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("EditListTitleTableViewCell", forIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            guard let colorPicker = UIStoryboard.instantiateViewController("ColorPickerViewController", storyboardName: "Lists") as? ColorPickerViewController else {
                return
            }
            guard let color = viewModel.color.value else {
                return
            }
            colorPicker.viewModel = ColorPickerViewModel(color: UIColor(hex: color))
            colorPicker.rx_color()
                .subscribeNext({ (color) in
                    let colorStr = (color.hexString() as NSString).substringFromIndex(1)
                    self.viewModel.update(nil, color: colorStr)
                })
                .addDisposableTo(disposeBag)
            // 選択状態を解除してからviewModelのupdateをかけないと，select時のbackgroundColorとしてsetされてしまう
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.navigationController?.pushViewController(colorPicker, animated: true)
            break
        default:
            break
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
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
    }
}