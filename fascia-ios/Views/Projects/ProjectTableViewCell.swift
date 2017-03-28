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
    @IBOutlet private weak var tilteLabel: UILabel!
    @IBOutlet private weak var githubLabel: UIImageView!
    @IBOutlet private weak var projectImage: UIImageView!
    @IBOutlet private weak var fasciaLabel: UIImageView!

    let disposeBag = DisposeBag()

    var viewModel: ProjectCellViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title.bindTo(self.tilteLabel.rx.text).addDisposableTo(disposeBag)
            vModel.githubRepository.subscribe(onNext: { (github) in
                self.githubLabel.isHidden = github
                self.fasciaLabel.isHidden = !github
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
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
