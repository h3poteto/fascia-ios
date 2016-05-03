//
//  ProjectTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProjectTableViewCell: UITableViewCell {
    @IBOutlet private weak var tilteLabel: UILabel!
    @IBOutlet private weak var githubLabel: UILabel!
    @IBOutlet private weak var projectImage: UIImageView!

    let disposeBag = DisposeBag()

    var viewModel: ProjectCellViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title.bindTo(self.tilteLabel.rx_text).addDisposableTo(disposeBag)
            vModel.hideRepository.bindTo(self.githubLabel.rx_hidden).addDisposableTo(disposeBag)
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
