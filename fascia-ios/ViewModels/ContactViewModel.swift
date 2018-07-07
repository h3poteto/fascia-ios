//
//  ContactViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2018/07/07.
//  Copyright © 2018年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ContactViewModel {
    final private(set) var isLoading = Variable(false)
    final let contactURL = FasciaAPIService.sharedInstance.contactURL
}
