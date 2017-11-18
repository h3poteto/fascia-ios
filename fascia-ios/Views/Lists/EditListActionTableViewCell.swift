//
//  EditListActionTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditListActionTableViewCell: UITableViewCell {
    @IBOutlet private weak var actionLabel: UILabel!
    private let disposeBag = DisposeBag()
    var viewModel: EditListViewModel? {
        didSet {
            guard let vModel = viewModel else { return }
            vModel.action
                .asObservable()
                .map { (text) -> String in
                    guard let text = text else { return "-" }
                    return text
                }
                .bind(to: actionLabel.rx.text)
                .disposed(by: disposeBag)
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

}
