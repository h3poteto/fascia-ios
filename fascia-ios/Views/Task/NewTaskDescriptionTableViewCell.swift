//
//  NewTaskDescriptionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/03/27.
//  Copyright © 2017年 h3poteto. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa

class NewTaskDescriptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var descriptionText: UITextView!
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
