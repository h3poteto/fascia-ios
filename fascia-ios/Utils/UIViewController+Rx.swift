//
//  UIViewController+Rx.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/16.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    fileprivate func trigger(_ selector: Selector) -> Observable<Void> {
        return rx.sentMessage(selector).map { _ in () }.shareReplay(1)
    }

    var rx_viewWillAppear: Observable<Void> {
        return trigger(#selector(self.viewWillAppear(_:)))
    }

    var rx_viewDidAppear: Observable<Void> {
        return trigger(#selector(self.viewDidAppear(_:)))
    }

    var rx_viewWillDisappear: Observable<Void> {
        return trigger(#selector(self.viewWillDisappear(_:)))
    }

    var rx_viewDidDisappear: Observable<Void> {
        return trigger(#selector(self.viewDidDisappear(_:)))
    }
}
