//
//  TaskDescriptionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/02/28.
//  Copyright © 2017年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskDescriptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var descriptionLabel: UILabel!
    private let disposeBag = DisposeBag()
    var viewModel: TaskViewModel? {
        didSet {
            guard let vModel = viewModel else { return }
            vModel.taskUpdated
                .asObservable()
                .map { (task) -> String in
                    guard let description = task?.taskDescription else { return "" }
                    return description
                }
                .bindTo(descriptionLabel.rx.text)
                .addDisposableTo(disposeBag)
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
