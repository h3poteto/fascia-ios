//
//  EditProjectDescriptionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/24.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProjectDescriptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var descriptionText: UITextView!
    private let disposeBag = DisposeBag()
    var viewModel: EditProjectViewModel? {
        didSet {
            guard let vModel = viewModel else { return }
            vModel.description
                .asObservable()
                .map { (description) -> String in
                    guard let desc = description else { return "" }
                    return desc
                }
                .bind(to: self.descriptionText.rx.text)
                .disposed(by: disposeBag)
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
        descriptionText
            .rx
            .text
            .subscribe(onNext: { (text) in
                self.viewModel?.update(title: nil, description: text)
            }, onError: nil, onCompleted: nil)
            .disposed(by: disposeBag)
    }
}
