//
//  NewProjectRepositoryTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewProjectRepositoryTableViewCell: UITableViewCell {
    @IBOutlet private weak var repositoryLabel: UILabel!
    @IBOutlet private weak var selectRepositoryLabel: UILabel!
    private let disposeBag = DisposeBag()
    var parentViewModel: NewProjectViewModel? {
        didSet {
            guard let vModel = self.parentViewModel else { return }
            vModel.repository
                .asObservable()
                .map({ (repository) -> String in
                    guard let fullName = repository?.fullName else {
                        return "-"
                    }
                    return fullName
                })
                .bindTo(self.selectRepositoryLabel.rx_text)
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
