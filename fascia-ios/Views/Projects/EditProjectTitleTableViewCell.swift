//
//  EditProjectTitleTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/22.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProjectTitleTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var titleText: UITextField!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: EditProjectViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.title
                .asObservable()
                .map { (title) -> String in
                    guard let title = title else { return "" }
                    return title
                }
                .bindTo(self.titleText.rx.text)
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
            .subscribe(onNext: { (text) in
                self.viewModel?.update(title: text, description: nil)
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)
    }

}
