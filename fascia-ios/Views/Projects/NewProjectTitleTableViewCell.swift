//
//  NewProjectTitleTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewProjectTitleTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleText: UITextField!

    private let disposeBag = DisposeBag()

    var parentViewModel: NewProjectViewModel? {
        didSet {
            guard let vModel = self.parentViewModel else { return }
            vModel.title
                .asObservable()
                .map({ (t) -> String in
                    guard let title = t else { return "" }
                    return title
                })
                .bindTo(self.titleText.rx.text)
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindViewModel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func bindViewModel() {
        titleText
            .rx
            .text
            .subscribe(onNext: { (text) in
                self.parentViewModel?.update(title: text, description: nil, repository: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

}
