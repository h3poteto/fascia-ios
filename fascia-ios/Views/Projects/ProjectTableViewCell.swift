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
import SESlideTableViewCell
import ChameleonFramework

class ProjectTableViewCell: SESlideTableViewCell {
    @IBOutlet fileprivate weak var tilteLabel: UILabel!
    @IBOutlet fileprivate weak var githubLabel: UIImageView!
    @IBOutlet fileprivate weak var projectImage: UIImageView!

    let disposeBag = DisposeBag()

    var viewModel: ProjectCellViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title.bindTo(self.tilteLabel.rx.text).addDisposableTo(disposeBag)
            vModel.hideRepository.bindTo(self.githubLabel.rx.isHidden).addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            projectImage.backgroundColor = UIColor(hexString: "42B8DD")
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            projectImage.backgroundColor = UIColor(hexString: "42B8DD")
        }
    }

}
