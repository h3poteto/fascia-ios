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
    @IBOutlet fileprivate weak var taskLabel: UILabel!
    @IBOutlet fileprivate weak var taskColorImage: UIImageView!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: TaskCellViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title.bindTo(self.taskLabel.rx.text).addDisposableTo(disposeBag)
            vModel.color.asObservable()
                .subscribe(onNext: { (color) in
                    self.taskColorImage.backgroundColor = color
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        guard let color = viewModel?.color else {
            return
        }
        if selected {
            taskColorImage.backgroundColor = color.value
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard let color = viewModel?.color else {
            return
        }
        if highlighted {
            taskColorImage.backgroundColor = color.value
        }
    }

}
