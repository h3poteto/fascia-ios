//
//  ListSectionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SESlideTableViewCell

class ListSectionTableViewCell: SESlideTableViewCell {
    @IBOutlet fileprivate weak var listTitle: UILabel!
    @IBOutlet fileprivate weak var expandImageView: UIImageView!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: ListSectionViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title.bindTo(self.listTitle.rx.text).addDisposableTo(disposeBag)
            vModel.isVisible
                .subscribe(onNext: { (visible) in
                    if visible {
                        self.expandImageView.image = UIImage(named: "Expand")
                    } else {
                        self.expandImageView.image = UIImage(named: "Contract")
                    }
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

        // Configure the view for the selected state
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel?.changeVisible()
    }
}
