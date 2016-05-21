//
//  NewListColorTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewListColorTableViewCell: UITableViewCell {
    @IBOutlet private weak var colorLabel: UILabel!
    @IBOutlet private weak var colorText: UITextField!
    @IBOutlet private weak var colorImage: UIImageView!
    var viewModel: NewListViewModel?
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        bindViewModel()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func bindViewModel() {
        colorText.rx_text
            .subscribeNext { (color) in
                self.viewModel?.update(nil, color: color)
            }
            .addDisposableTo(disposeBag)
    }
}
