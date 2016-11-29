//
//  EditListTitleTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditListTitleTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleText: UITextField!
    private let disposeBag = DisposeBag()
    var viewModel: EditListViewModel? {
        didSet {
            guard let vModel = viewModel else { return }
            vModel.title
                .asObservable()
                .map { (text) -> String in
                    guard let text = text else { return "" }
                    return text
                }
                .bindTo(titleText.rx.text)
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
                self.viewModel?.update(title: text, color: nil, option: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

}
