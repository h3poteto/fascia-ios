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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryTableViewCell", for: indexPath) as? RepositoryTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        }
        let repository = viewModel.repositories[indexPath.row]
        cell.viewModel = RepositoryCellViewModel(model: repository)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRepository.value = viewModel.repositories[indexPath.row]
        self.navigationController?.popViewController(animated: true)
    }

    private func bindViewModel() {
        viewModel.dataUpdated
            .drive(onNext: { (_) in
                self.tableView.reloadData()
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

}
