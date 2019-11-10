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
    private final let action = SessionAction()
    final private(set) var isLoading = BehaviorRelay(value: false)
    final let signInURL = FasciaAPIService.sharedInstance.signInURL

    func update() {
        action.updateSession()
    }
}
