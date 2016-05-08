//
//  TaskTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskTableViewCell: UITableViewCell {
    @IBOutlet private weak var taskLabel: UILabel!
    @IBOutlet private weak var taskColorImage: UIImageView!
    private let disposeBag = DisposeBag()
    var viewModel: TaskCellViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title.bindTo(self.taskLabel.rx_text).addDisposableTo(disposeBag)
            vModel.color.asObservable()
                .subscribeNext { (color) in
                    self.taskColorImage.backgroundColor = color
                }
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        guard let color = viewModel?.color else {
            return
        }
        if selected {
            taskColorImage.backgroundColor = color.value
        }
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard let color = viewModel?.color else {
            return
        }
        if highlighted {
            taskColorImage.backgroundColor = color.value
        }
    }

}
