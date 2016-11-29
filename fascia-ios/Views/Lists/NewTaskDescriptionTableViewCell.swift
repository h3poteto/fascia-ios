//
//  NewTaskDescriptionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewTaskDescriptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionText: UITextField!
    var viewModel: NewTaskViewModel?
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        bindViewModel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func bindViewModel() {
        descriptionText
            .rx
            .text
            .subscribe(onNext: { (text) in
                self.viewModel?.update(title: nil, description: text)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
