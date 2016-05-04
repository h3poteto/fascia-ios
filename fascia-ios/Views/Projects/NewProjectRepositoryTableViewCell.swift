//
//  NewProjectRepositoryTableViewCell.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit

class NewProjectRepositoryTableViewCell: UITableViewCell {
    @IBOutlet private weak var repositoryLabel: UILabel!
    @IBOutlet private weak var selectRepositoryLabel: UILabel!
    var parentViewModel: NewProjectViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
