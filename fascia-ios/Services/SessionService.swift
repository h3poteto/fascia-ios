//
//  SessionService.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/02/21.
//  Copyright © 2017年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class SessionService {
    private final let action = SessionAction()

    func fetch() {
        action.updateSession()
    }
}
