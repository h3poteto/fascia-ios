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
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionText: UITextField!

    fileprivate let disposeBag = DisposeBag()

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

    fileprivate func bindViewModel() {
        descriptionText
            .rx
            .text
            .subscribe(onNext: { (text) in
                self.parentViewModel?.update(nil, description: text, repository: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
