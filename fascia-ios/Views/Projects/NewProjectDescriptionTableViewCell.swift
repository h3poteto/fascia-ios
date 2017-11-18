//
//  NewProjectDescriptionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewProjectDescriptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var descriptionText: UITextView!

    private let disposeBag = DisposeBag()

    var parentViewModel: NewProjectViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
                self.parentViewModel?.update(title: nil, description: text, repository: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
