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
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleText: UITextField!
    var viewModel: NewListViewModel?
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindViewModel()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func bindViewModel() {
        titleText.rx_text
            .subscribeNext { (title) in
                self.viewModel?.update(title, color: nil)
            }
            .addDisposableTo(disposeBag)
    }
}
