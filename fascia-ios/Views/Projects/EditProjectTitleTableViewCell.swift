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
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleText: UITextField!
    private let disposeBag = DisposeBag()
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

    private func bindViewModel() {
        titleText
            .rx
            .text
            .subscribe(onNext: { (text) in
                self.viewModel?.update(title: text, description: nil)
            }, onError: nil, onCompleted: nil)
            .addDisposableTo(disposeBag)
    }

}
