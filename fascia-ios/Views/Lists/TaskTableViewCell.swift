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
            vModel.title.bind(to: self.taskLabel.rx.text).disposed(by: disposeBag)
            vModel.color.asObservable()
                .subscribe(onNext: { (color) in
                    self.taskColorImage.backgroundColor = color
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
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
