//
//  SignInViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/01.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class SignInViewModel {
    fileprivate final let action = SessionAction()
    final fileprivate(set) var isLoading = Variable(false)
    final let signInURL = FasciaAPIService.sharedInstance.signInURL

    func update() {
        action.updateSession()
    }
}
