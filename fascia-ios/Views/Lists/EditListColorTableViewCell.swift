//
//  EditListColorTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditListColorTableViewCell: UITableViewCell {
    @IBOutlet private weak var colorImage: UIImageView!
    private let disposeBag = DisposeBag()
    var viewModel: EditListViewModel? {
        didSet {
            guard let vModel = self.viewModel else { return }
            vModel.color.asObservable()
                .subscribeNext { (colorStr) in
                    guard let colorString = colorStr else { return }
                    let color = UIColor(hex: colorString)
                    self.colorImage.backgroundColor = color
                }
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard let color = viewModel?.color.value else {
            return
        }
        if selected {
            colorImage.backgroundColor = UIColor(hex: color)
        }
        // Configure the view for the selected state
    }

}
