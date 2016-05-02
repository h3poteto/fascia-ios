//
//  SignInViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/01.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import Foundation

class SignInViewModel {
    private final let action = SessionAction()

    func update() {
        action.updateSession()
    }
}
