//
//  NewListTitleTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewListTitleTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var titleText: UITextField!
    var viewModel: NewListViewModel?
    fileprivate let disposeBag = DisposeBag()

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
        titleText
            .rx
            .text
            .subscribe(onNext: {(title) in
                self.viewModel?.update(title: title, color: nil)
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)
    }
}
