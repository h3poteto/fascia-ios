//
//  RepositoryTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!

    let disposeBag = DisposeBag()

    var viewModel: RepositoryCellViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.fullName.bindTo(self.nameLabel.rx_text).addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
