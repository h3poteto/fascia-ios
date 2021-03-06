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
import Down

class TaskDescriptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    private let disposeBag = DisposeBag()
    var viewModel: TaskViewModel? {
        didSet {
            guard let vModel = viewModel else { return }
            vModel.taskUpdated
                .asObservable()
                .map({ (task) -> NSAttributedString in
                    guard let description = task?.taskMarkedDescription else { return NSAttributedString(string: "") }
                    return description
                })
                .bind(to: descriptionLabel.rx.attributedText)
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
