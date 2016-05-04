//
//  RepositoriesTableViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoriesTableViewController: UITableViewController {
    var viewModel: RepositoriesViewModel!
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
        return viewModel.repositories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryTableViewCell", forIndexPath: indexPath) as? RepositoryTableViewCell else {
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        let repository = viewModel.repositories[indexPath.row]
        cell.viewModel = RepositoryCellViewModel(model: repository)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.selectedRepository.value = viewModel.repositories[indexPath.row]
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func bindViewModel() {
        viewModel.dataUpdated
            .driveNext { (repositories) in
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }

}
