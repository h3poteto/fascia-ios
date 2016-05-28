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
                .bindTo(titleText.rx_text)
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bindViewModel()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func bindViewModel() {
        titleText.rx_text
            .subscribeNext { (text) in
                self.viewModel?.update(text, color: nil, option: nil)
            }
            .addDisposableTo(disposeBag)
    }

}
