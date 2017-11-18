//
//  TaskTitleTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/02/28.
//  Copyright © 2017年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskTitleTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    private let disposeBag = DisposeBag()
    var viewModel: TaskViewModel? {
        didSet {
            guard let vModel = viewModel else { return }
            vModel.taskUpdated
                .asObservable()
                .map { (task) -> String in
                    guard let title = task?.title else { return "" }
                    return title
                }
                .bind(to: titleLabel.rx.text)
                .disposed(by: disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
