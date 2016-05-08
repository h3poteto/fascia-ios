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
    @IBOutlet private weak var githubLabel: UIImageView!
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

        if selected {
            projectImage.backgroundColor = UIColor(hexString: "42B8DD", alpha: 1.0)
        }
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            projectImage.backgroundColor = UIColor(hexString: "42B8DD", alpha: 1.0)
        }
    }

}
